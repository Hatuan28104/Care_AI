import { getDB } from "../config/db.js";
import jwt from "jsonwebtoken";
import crypto from "node:crypto";
import admin from "../config/firebase.js";

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
   FIREBASE PHONE LOGIN
========================= */
export async function firebasePhoneLogin(idToken, req) {
  if (!idToken || typeof idToken !== "string") {
    throw new Error("Thiếu Firebase ID token");
  }

  const decoded = await admin.auth().verifyIdToken(idToken);

  const firebasePhone = decoded.phone_number;
  if (!firebasePhone) {
    throw new Error("Token Firebase không có số điện thoại");
  }

  const db = getDB();
  const localPhone = normalizeVnPhone(firebasePhone);

  let { data: user, error: userError } = await db
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

  if (userError) throw userError;

  if (!user) {
    const timestamp = Date.now().toString().slice(-10);
    const newUserId = "ND" + timestamp;
    const newAccountId = "TK" + timestamp;

    const { error: nguoiDungError } = await db.from("nguoidung").insert({
      nguoidung_id: newUserId,
      tennd: null,
    });

    if (nguoiDungError) throw nguoiDungError;

    const { error: taiKhoanError } = await db.from("taikhoan").insert({
      taikhoan_id: newAccountId,
      nguoidung_id: newUserId,
      sodienthoai: localPhone,
      laadmin: false,
      ngaytao: new Date().toISOString().slice(0, 10),
    });

    if (taiKhoanError) throw taiKhoanError;

    user = {
      taikhoan_id: newAccountId,
      sodienthoai: localPhone,
      nguoidung: {
        nguoidung_id: newUserId,
        tennd: null,
        ngaysinh: null,
        gioitinh: null,
        chieucao: null,
        cannang: null,
      },
    };
  }

  const token = jwt.sign(
    {
      nguoidung_id: user.nguoidung.nguoidung_id,
      taikhoan_id: user.taikhoan_id,
      sodienthoai: user.sodienthoai,
      laadmin: false,
    },
    process.env.JWT_SECRET || "secret",
    { expiresIn: "7d" }
  );

  const { device, ip: bodyIp } = req.body || {};
  const ip =
    bodyIp ||
    req.headers["x-forwarded-for"]?.split(",")[0] ||
    req.socket.remoteAddress ||
    "";

  const { error: loginHistoryError } = await db
    .from("lichsudangnhap")
    .insert({
      lichsu_id: crypto.randomUUID(),
      thoigian: new Date().toISOString(),
      thietbi: device && device.trim() !== "" ? device : "Unknown",
      diachi: ip || null,
      ip: ip || null,
      taikhoan_id: user.taikhoan_id,
    });

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
  const inputPassword = String(password || "").trim();
  const dbPassword = String(account?.matkhau || "").trim();

  const ok = account && dbPassword && inputPassword === dbPassword;

  if (!ok) {
    throw new Error("Số điện thoại hoặc mật khẩu không đúng");
  }

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

/* =========================
   ADMIN - CHANGE PASSWORD
   ========================= */
export async function changeAdminPassword(taikhoanId, oldPw, newPw) {
  const db = getDB();

  // 1. Check old password
  const { data: account, error: fetchErr } = await db
    .from("taikhoan")
    .select("matkhau")
    .eq("taikhoan_id", taikhoanId)
    .maybeSingle();

  if (fetchErr) throw fetchErr;
  if (!account) throw new Error("Tài khoản không tồn tại");

  if (String(account.matkhau).trim() !== String(oldPw).trim()) {
    throw new Error("Mật khẩu cũ không chính xác");
  }

  // 2. Update to new password
  const { error: updateErr } = await db
    .from("taikhoan")
    .update({ matkhau: String(newPw).trim() })
    .eq("taikhoan_id", taikhoanId);

  if (updateErr) throw updateErr;

  return true;
}
