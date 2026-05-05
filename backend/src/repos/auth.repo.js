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
async function sendOtpTelegram(localPhone, otp) {
  if (!process.env.TELEGRAM_BOT_TOKEN || !process.env.TELEGRAM_CHAT_ID) {
    throw new Error("Thieu cau hinh Telegram OTP");
  }

  const chatIds = process.env.TELEGRAM_CHAT_ID
    .split(",")
    .map((id) => id.trim())
    .filter(Boolean);

  if (chatIds.length === 0) {
    throw new Error("Thieu Telegram chat ID");
  }

  let sent = false;

  for (const chatId of chatIds) {
    const url = `https://api.telegram.org/bot${process.env.TELEGRAM_BOT_TOKEN}/sendMessage`;

    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        chat_id: chatId,
        text: `CareAI OTP\nPhone: ${localPhone}\nOTP: ${otp}\nHet han: 2 phut`,
      }),
    });

    const data = await response.json();

    if (!response.ok || data.ok !== true) {
      console.error("Telegram OTP failed:", {
        chatId,
        response: data,
      });
    } else {
      sent = true;
      console.log("Telegram OTP sent:", {
        chatId,
        phone: localPhone,
        messageId: data.result?.message_id,
      });
    }
  }

  if (!sent) {
    throw new Error("Khong the gui OTP Telegram");
  }
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

function hashPassword(password) {
  const salt = crypto.randomBytes(16).toString("hex");
  const hash = crypto.scryptSync(String(password), salt, 64).toString("hex");
  return `scrypt:${salt}:${hash}`;
}

function passwordMatches(inputPassword, storedPassword) {
  const input = String(inputPassword || "").trim();
  const stored = String(storedPassword || "").trim();

  if (!stored.startsWith("scrypt:")) {
    return input === stored;
  }

  const [, salt, storedHash] = stored.split(":");
  if (!salt || !storedHash) return false;

  const inputHash = crypto.scryptSync(input, salt, 64);
  const storedBuffer = Buffer.from(storedHash, "hex");

  return storedBuffer.length === inputHash.length &&
    crypto.timingSafeEqual(storedBuffer, inputHash);
}

function getValidOtp(localPhone, allowedPurposes) {
  const data = otpStore.get(localPhone);
  if (!data) throw new Error("OTP không tồn tại");

  if (Date.now() > data.expires) {
    otpStore.delete(localPhone);
    throw new Error("OTP hết hạn");
  }

  if (!allowedPurposes.includes(data.purpose)) {
    throw new Error("OTP không hợp lệ");
  }

  return data;
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
   REGISTER - REQUEST OTP
========================= */
export async function requestRegisterOtp(phone) {
  const db = getDB();
  const localPhone = normalizeVnPhone(phone);

  if (await phoneExists(db, localPhone)) {
    throw new Error("Số điện thoại đã được đăng ký");
  }

  const otp = generateOtp();
  otpStore.set(localPhone, {
    otp,
    expires: Date.now() + 2 * 60 * 1000,
    purpose: "register",
  });

  await sendOtpTelegram(localPhone, otp);
}

/* =========================
   LOGIN - REQUEST OTP
========================= */
export async function requestLoginOtp(phone) {
  const db = getDB();
  const localPhone = normalizeVnPhone(phone);

  if (!(await phoneExists(db, localPhone))) {
    throw new Error("Số điện thoại chưa đăng ký");
  }

  const otp = generateOtp();
  otpStore.set(localPhone, {
    otp,
    expires: Date.now() + 2 * 60 * 1000,
    purpose: "login",
  });

  await sendOtpTelegram(localPhone, otp);
}

/* =========================
   VERIFY OTP
========================= */
export async function verifyOtp(phone, otp, req, deviceId) {
  const localPhone = normalizeVnPhone(phone);
  const data = getValidOtp(localPhone, ["register", "login"]);

  if (data.otp !== otp) {
    throw new Error("OTP không đúng");
  }

  otpStore.delete(localPhone);

  const db = getDB();

  /* ===== CHECK USER ===== */
  let { data: user, error: findUserError } = await db
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

  if (findUserError) throw findUserError;

  /* ===== CREATE IF NOT EXIST ===== */
  if (!user) {
    const newUserId = "ND" + Date.now().toString().slice(-10);
    const newAccountId = "TK" + Date.now().toString().slice(-10);

    const { error: accountInsertError } = await db.from("taikhoan").insert({
      taikhoan_id: newAccountId,
      nguoidung_id: null,
      sodienthoai: localPhone,
      laadmin: false,
      ngaytao: new Date().toISOString().slice(0, 10),
    });

    if (accountInsertError) throw accountInsertError;

    const { error: profileInsertError } = await db.from("nguoidung").insert({
      nguoidung_id: newUserId,
      tennd: null,
    });

    if (profileInsertError) {
      await db.from("taikhoan").delete().eq("taikhoan_id", newAccountId);
      throw profileInsertError;
    }

    const { error: accountUpdateError } = await db
      .from("taikhoan")
      .update({ nguoidung_id: newUserId })
      .eq("taikhoan_id", newAccountId);

    if (accountUpdateError) {
      await db.from("nguoidung").delete().eq("nguoidung_id", newUserId);
      await db.from("taikhoan").delete().eq("taikhoan_id", newAccountId);
      throw accountUpdateError;
    }

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
  const inputPassword = String(password || "").trim();
  const dbPassword = String(account?.matkhau || "").trim();

  const ok = account && dbPassword && passwordMatches(inputPassword, dbPassword);

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

  if (!passwordMatches(oldPw, account.matkhau)) {
    throw new Error("Mật khẩu cũ không chính xác");
  }

  // 2. Update to new password
  const { error: updateErr } = await db
    .from("taikhoan")
    .update({ matkhau: hashPassword(newPw) })
    .eq("taikhoan_id", taikhoanId);

  if (updateErr) throw updateErr;

  return true;
}

export async function requestAdminPasswordResetOtp(phone) {
  const db = getDB();
  const localPhone = normalizeVnPhone(phone);

  const { data: account, error } = await db
    .from("taikhoan")
    .select("taikhoan_id")
    .eq("sodienthoai", localPhone)
    .eq("laadmin", true)
    .maybeSingle();

  if (error) throw error;
  if (!account) throw new Error("Số điện thoại admin không tồn tại");

  const otp = generateOtp();
  otpStore.set(localPhone, {
    otp,
    expires: Date.now() + 2 * 60 * 1000,
    purpose: "admin-password-reset",
  });

  await sendOtpTelegram(localPhone, otp);
}

export async function verifyAdminPasswordResetOtp(phone, otp) {
  const db = getDB();
  const localPhone = normalizeVnPhone(phone);
  const data = getValidOtp(localPhone, ["admin-password-reset"]);

  if (data.otp !== otp) {
    throw new Error("OTP không đúng");
  }

  const { data: account, error } = await db
    .from("taikhoan")
    .select("taikhoan_id")
    .eq("sodienthoai", localPhone)
    .eq("laadmin", true)
    .maybeSingle();

  if (error) throw error;
  if (!account) throw new Error("Tài khoản admin không tồn tại");

  return true;
}

export async function resetAdminPasswordWithOtp(phone, otp, newPassword) {
  const db = getDB();
  const localPhone = normalizeVnPhone(phone);
  const data = getValidOtp(localPhone, ["admin-password-reset"]);

  if (data.otp !== otp) {
    throw new Error("OTP không đúng");
  }

  const { data: account, error: fetchError } = await db
    .from("taikhoan")
    .select("taikhoan_id")
    .eq("sodienthoai", localPhone)
    .eq("laadmin", true)
    .maybeSingle();

  if (fetchError) throw fetchError;
  if (!account) throw new Error("Tài khoản admin không tồn tại");

  const { error: updateError } = await db
    .from("taikhoan")
    .update({ matkhau: hashPassword(newPassword) })
    .eq("taikhoan_id", account.taikhoan_id);

  if (updateError) throw updateError;

  otpStore.delete(localPhone);
  return true;
}
