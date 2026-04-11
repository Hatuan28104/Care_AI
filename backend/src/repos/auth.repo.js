import { getDB } from "../config/db.js";
import jwt from "jsonwebtoken";
import crypto from "node:crypto";
import admin from "../config/firebase.js";

const otpStore = new Map();

/* =========================
   HELPER
========================= */
function normalizeVnPhone(phone) {
  let digits = phone.replace(/\D/g, "");

  if (digits.startsWith("84")) {
    digits = "0" + digits.slice(2);
  }

  if (digits.length !== 10) {
    throw new Error("Số điện thoại không hợp lệ");
  }

  return digits;
}

async function phoneExists(db, phone) {
  const { data, error } = await db
    .from("taikhoan")
    .select("sodienthoai")
    .eq("sodienthoai", phone)
    .maybeSingle();

  if (error) throw error;
  return !!data;
}

function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

function isProfileCompleted(nguoidung) {
  if (!nguoidung) return false;
  const name = String(nguoidung.tennd || "").trim().toLowerCase();
  const hasName =
    name.length > 0 && name !== "người dùng mới" && name !== "nguoi dung moi";
  const hasDob = !!nguoidung.ngaysinh;
  const hasGender = typeof nguoidung.gioitinh === "boolean";
  const hasHeight = Number(nguoidung.chieucao) > 0;
  const hasWeight = Number(nguoidung.cannang) > 0;
  return hasName && hasDob && hasGender && hasHeight && hasWeight;
}

/* =========================
   REGISTER – REQUEST OTP
========================= */
export async function requestRegisterOtp(phone) {
  const db = getDB();
  const localPhone = normalizeVnPhone(phone);

  if (await phoneExists(db, localPhone)) {
    throw new Error("Số điện thoại đã được đăng ký");
  }

  const otp = generateOtp();
  otpStore.set(phone, {
    otp,
    expires: Date.now() + 2 * 60 * 1000,
  });

  console.log(`REGISTER OTP ${phone}: ${otp}`);
}

/* =========================
   LOGIN – REQUEST OTP
========================= */
export async function requestLoginOtp(phone) {
  const db = getDB();
  const localPhone = normalizeVnPhone(phone);

  if (!(await phoneExists(db, localPhone))) {
    throw new Error("Số điện thoại chưa đăng ký");
  }

  const otp = generateOtp();
  otpStore.set(phone, {
    otp,
    expires: Date.now() + 2 * 60 * 1000,
  });

  console.log(`LOGIN OTP ${phone}: ${otp}`);
}

/* =========================
   VERIFY OTP
========================= */
export async function verifyOtp(phone, otp, req, deviceId) {
  const data = otpStore.get(phone);

  const isDevBypass =
    process.env.DEV_MODE === "true" && otp === "123456";

  if (!isDevBypass) {
    if (!data) throw new Error("OTP không tồn tại");
    if (Date.now() > data.expires) throw new Error("OTP hết hạn");
    if (data.otp !== otp) throw new Error("OTP không đúng");

    otpStore.delete(phone);
  } else {
    console.log("🔥 DEV MODE OTP BYPASS:", phone);

    otpStore.delete(phone);
  }

  const db = getDB();
  const localPhone = normalizeVnPhone(phone);

  /* ===== CHECK USER ===== */
  let { data: user } = await db
    .from("taikhoan")
    .select(`
      taikhoan_id,
      sodienthoai,
      nguoidung:nguoidung_id (
        nguoidung_id,
        tennd,
        ngaysinh,
        gioitinh,
        chieucao,
        cannang
      )
    `)
    .eq("sodienthoai", localPhone)
    .maybeSingle();

  /* ===== CREATE IF NOT EXIST ===== */
  if (!user) {
    const newUserId = "ND" + Date.now().toString().slice(-10);
    const newAccountId = "TK" + Date.now().toString().slice(-10);

    await Promise.all([
      db.from("nguoidung").insert({
        nguoidung_id: newUserId,
        tennd: null,
      }),
      db.from("taikhoan").insert({
        taikhoan_id: newAccountId,
        nguoidung_id: newUserId,
        sodienthoai: localPhone,
        laadmin: false,
        ngaytao: new Date().toISOString().slice(0, 10),
      })
    ]);

    user = {
      taikhoan_id: newAccountId,
      sodienthoai: localPhone,
      nguoidung: {
        nguoidung_id: newUserId,
        tennd: null,
      },
    };
  }

  const token = jwt.sign({
      nguoidung_id: user.nguoidung.nguoidung_id,
      taikhoan_id: user.taikhoan_id,
      sodienthoai: user.sodienthoai,
      laadmin: false,
    },
    process.env.JWT_SECRET || "secret",
    { expiresIn: "7d" }
  );

  /* ===== LOGIN HISTORY ===== */
  const { device, ip: bodyIp } = req.body || {};
  const ip =
    bodyIp ||
    req.headers["x-forwarded-for"]?.split(",")[0] ||
    req.socket.remoteAddress ||
    "";

  const insertData = {
    lichsu_id: crypto.randomUUID(),
    thoigian: new Date().toISOString(),
    thietbi: device && device.trim() !== "" ? device : "Unknown",
    diachi: ip || null,
    ip: ip || null,
    taikhoan_id: user.taikhoan_id,
  };

  const { error: loginHistoryError } = await db
    .from("lichsudangnhap")
    .insert(insertData);

  if (loginHistoryError) {
    console.error("Insert login history failed", {
      error: loginHistoryError,
      taikhoan_id: user.taikhoan_id,
    });
  }

  return {
    success: true,
    user,
    token,
    profileCompleted: isProfileCompleted(user?.nguoidung),
  };
}

export async function adminLogin(phone, password, req) {
  const db = getDB();
  const localPhone = normalizeVnPhone(phone);

  const { data: account, error } = await db
    .from("taikhoan")
    .select("taikhoan_id, sodienthoai, laadmin, matkhau, nguoidung_id")
    .eq("sodienthoai", localPhone)
    .eq("laadmin", true)
    .maybeSingle();

  if (error) throw error;
  if (!account) throw new Error("Tài khoản admin không tồn tại");
  if (!account.matkhau) throw new Error("Tài khoản admin chưa cấu hình mật khẩu");

  const ok = String(password) === String(account.matkhau);
  if (!ok) throw new Error("Số điện thoại hoặc mật khẩu không đúng");

  const token = jwt.sign(
    {
      taikhoan_id: account.taikhoan_id,
      sodienthoai: account.sodienthoai,
      nguoidung_id: account.nguoidung_id || null,
      laadmin: true,
    },
    process.env.JWT_SECRET || "secret",
    { expiresIn: "7d" }
  );

  const ip =
    req?.headers?.["x-forwarded-for"]?.split(",")[0] ||
    req?.socket?.remoteAddress ||
    "";
  const device = req?.body?.device || "Web Admin";

  const { error: loginHistoryError } = await db
    .from("lichsudangnhap")
    .insert({
      lichsu_id: crypto.randomUUID(),
      thoigian: new Date().toISOString(),
      thietbi: device,
      diachi: ip || null,
      ip: ip || null,
      taikhoan_id: account.taikhoan_id,
    });

  if (loginHistoryError) {
    console.error("Insert admin login history failed", {
      error: loginHistoryError,
      taikhoan_id: account.taikhoan_id,
    });
  }

  return {
    success: true,
    token,
    user: {
      taikhoan_id: account.taikhoan_id,
      sodienthoai: account.sodienthoai,
      laadmin: true,
    },
  };
}

/* =========================
   CHANGE PHONE
========================= */
export async function changePhone(userId, newPhone) {
  const db = getDB();
  const phone = normalizeVnPhone(newPhone);

  if (await phoneExists(db, phone)) {
    throw new Error("Số điện thoại đã tồn tại");
  }

  const { error } = await db
    .from("taikhoan")
    .update({ sodienthoai: phone })
    .eq("nguoidung_id", userId);

  if (error) throw error;

  return true;
}

/* =========================
   LOGIN HISTORY
========================= */
export async function getLoginHistory(taikhoanId) {
  const db = getDB();

  const { data, error } = await db
    .from("lichsudangnhap")
    .select("thoigian, thietbi, ip")
    .eq("taikhoan_id", taikhoanId)
    .order("thoigian", { ascending: false })
    .limit(10);

  if (error) throw error;

  return data;
}

/* =========================
   FCM TOKEN
========================= */
export async function saveFcmToken(userId, token) {
  const db = getDB();

  await db.from("fcmtokens").delete().eq("token", token);

  const { error } = await db.from("fcmtokens").insert({
    fcmtoken_id: "FCM" + Date.now().toString().slice(-10),
    nguoidung_id: userId,
    token,
  });

  if (error) throw error;

  return true;
}

export async function removeFcmToken(token) {
  const db = getDB();

  await db.from("fcmtokens").delete().eq("token", token);

  return true;
}
export async function sendTestPush(userId) {
  const db = getDB();

  const { data, error } = await db
    .from("fcmtokens")
    .select("token")
    .eq("nguoidung_id", userId);

  if (error) throw error;
  if (!data || data.length === 0) {
    throw new Error("User chưa có FCM token");
  }

  for (let t of data) {
    await admin.messaging().send({
      token: t.token,
      notification: {
        title: "CareAI",
        body: "Thông báo test thành công!",
      },
    });
  }

  return true;
}
