import sql from "mssql";
import { getDB } from "../config/db.js";
import jwt from "jsonwebtoken";
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

async function phoneExists(db, localPhone) {
  const rs = await db
    .request()
    .input("sdt", sql.NVarChar(10), localPhone)
    .query("SELECT 1 FROM TaiKhoan WHERE SoDienThoai = @sdt");

  return rs.recordset.length > 0;
}

function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

/* =========================
   REGISTER – REQUEST OTP
========================= */
export async function requestRegisterOtp(phone) {
  const db = await getDB();
  const localPhone = normalizeVnPhone(phone);

  if (await phoneExists(db, localPhone)) {
    throw new Error("Số điện thoại đã được đăng ký");
  }

  const otp = generateOtp();
  otpStore.set(phone, {
    otp,
    expires: Date.now() + 2 * 60 * 1000,
  });

  console.log(`📩 REGISTER OTP ${phone}: ${otp}`);
}

/* =========================
   LOGIN – REQUEST OTP
========================= */
export async function requestLoginOtp(phone) {
  const db = await getDB();
  const localPhone = normalizeVnPhone(phone);

  if (!(await phoneExists(db, localPhone))) {
    throw new Error("Số điện thoại chưa đăng ký tài khoản");
  }

  const otp = generateOtp();
  otpStore.set(phone, {
    otp,
    expires: Date.now() + 2 * 60 * 1000,
  });

  console.log(`📩 LOGIN OTP ${phone}: ${otp}`);
}

/* =========================
   VERIFY OTP (CHUNG)
========================= */
export async function verifyOtp(phone, otp, req) {
  const data = otpStore.get(phone);
  if (!data) throw new Error("OTP không tồn tại");
  if (Date.now() > data.expires) throw new Error("OTP hết hạn");
  if (data.otp !== otp) throw new Error("OTP không đúng");

  otpStore.delete(phone);

  const db = await getDB();
  const localPhone = normalizeVnPhone(phone);

  if (!(await phoneExists(db, localPhone))) {
    const rs = await db
      .request()
      .input("sodienthoai", sql.NVarChar(10), localPhone)
      .output("ret", sql.Bit)
      .execute("dbo.sp_TaoTaiKhoan");

    if (!rs.output.ret) throw new Error("Tạo tài khoản thất bại");
  }

  const userRs = await db
    .request()
    .input("sdt", sql.NVarChar(10), localPhone)
    .query(`
      SELECT 
        TK.SoDienThoai,
        ND.NguoiDung_ID,
        ND.TenND
      FROM TaiKhoan TK
      JOIN NguoiDung ND ON TK.NguoiDung_ID = ND.NguoiDung_ID
      WHERE TK.SoDienThoai = @sdt
    `);

  const user = userRs.recordset[0];

  const token = jwt.sign(
    {
      NguoiDung_ID: user.NguoiDung_ID,
      SoDienThoai: user.SoDienThoai,
    },
    process.env.JWT_SECRET || "my_secret_key",
    { expiresIn: "7d" }
  );

  /* ========= LOGIN HISTORY ========= */
  const userAgent = req.headers["user-agent"] || "Unknown";
  const ip =
    req.headers["x-forwarded-for"]?.split(",")[0] ||
    req.socket.remoteAddress ||
    "";

  await db
    .request()
    .input("uid", sql.Char(12), user.NguoiDung_ID)
    .input("device", sql.NVarChar(255), userAgent)
    .input("ip", sql.NVarChar(50), ip)
    .query(`
      INSERT INTO LichSuDangNhap (
        LichSu_ID,
        NguoiDung_ID,
        ThietBi,
        IP,
        ThoiGian
      )
      VALUES (
        'LS' + RIGHT(REPLACE(NEWID(), '-', ''), 10),
        @uid,
        @device,
        @ip,
        GETDATE()
      )
    `);

  return {
    success: true,
    message: "Xác thực thành công",
    user,
    token,
  };
}

/* =========================
   CHANGE PHONE
========================= */
export async function changePhone(userId, newPhone) {
  const db = await getDB();
  const localPhone = normalizeVnPhone(newPhone);

  if (await phoneExists(db, localPhone)) {
    throw new Error("Số điện thoại đã tồn tại");
  }

  await db
    .request()
    .input("uid", sql.Char(12), userId)
    .input("phone", sql.NVarChar(10), localPhone)
    .query(`
      UPDATE TaiKhoan
      SET SoDienThoai = @phone
      WHERE NguoiDung_ID = @uid
    `);

  return true;
}

/* =========================
   LOGIN HISTORY
========================= */
export async function getLoginHistory(userId) {
  const db = await getDB();

  const rs = await db
    .request()
    .input("uid", sql.Char(12), userId)
    .query(`
      SELECT TOP 10
        ThoiGian,
        ThietBi,
        IP
      FROM LichSuDangNhap
      WHERE NguoiDung_ID = @uid
      ORDER BY ThoiGian DESC
    `);

  return rs.recordset;
}
/* =========================
   SAVE FCM TOKEN
========================= */
export async function saveFcmToken(userId, fcmToken) {
  const db = await getDB();

  await db
    .request()
    .input("uid", sql.Char(12), userId)
    .input("fcm", sql.NVarChar(255), fcmToken)
    .query(`
      UPDATE NguoiDung
      SET FcmToken = @fcm
      WHERE NguoiDung_ID = @uid
    `);

  return true;
}
export async function sendTestPush(userId) {
  const db = await getDB();

  const rs = await db
    .request()
    .input("uid", sql.Char(12), userId)
    .query("SELECT FcmToken FROM NguoiDung WHERE NguoiDung_ID = @uid");

  const token = rs.recordset[0]?.FcmToken;

  if (!token) throw new Error("User chưa có FCM token");

  await admin.messaging().send({
    token,
    notification: {
      title: "🔥 CareAI",
      body: "Thông báo test thành công!",
    },
  });

  return true;
}