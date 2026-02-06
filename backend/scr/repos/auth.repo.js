import sql from "mssql";
import { getDB } from "../../db.js";
import jwt from "jsonwebtoken";

const otpStore = new Map();

/* =========================
   HELPER
========================= */
function normalizeVnPhone(phone) {
  let digits = phone.replace(/\D/g, '');

  if (digits.startsWith('84')) {
    digits = '0' + digits.slice(2);
  }

  if (digits.length !== 10) {
    throw new Error("Số điện thoại không hợp lệ");
  }

  return digits;
}

async function phoneExists(db, localPhone) {
  const rs = await db.request()
    .input("sdt", sql.NVarChar(10), localPhone)
    .query("SELECT 1 FROM TaiKhoan WHERE SoDienThoai = @sdt");

  return rs.recordset.length > 0;
}

function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

/* =========================
   REGISTER – GỬI OTP
========================= */
export async function requestRegisterOtp(phone) {
  const db = await getDB();
  const localPhone = normalizeVnPhone(phone);

  const exists = await phoneExists(db, localPhone);
  if (exists) {
    throw new Error("Số điện thoại đã được đăng ký");
  }

  const otp = generateOtp();

  otpStore.set(phone, {
    otp,
    expires: Date.now() + 2 * 60 * 1000,
  });

  console.log(`📩 REGISTER OTP cho ${phone}:`, otp);
}

/* =========================
   LOGIN – GỬI OTP
========================= */
export async function requestLoginOtp(phone) {
  const db = await getDB();
  const localPhone = normalizeVnPhone(phone);

  const exists = await phoneExists(db, localPhone);
  if (!exists) {
    throw new Error("Số điện thoại chưa đăng ký tài khoản");
  }

  const otp = generateOtp();

  otpStore.set(phone, {
    otp,
    expires: Date.now() + 2 * 60 * 1000,
  });

  console.log(`📩 LOGIN OTP cho ${phone}:`, otp);
}

/* =========================
   VERIFY OTP (DÙNG CHUNG)
========================= */
export async function verifyOtp(phone, otp) {
  const data = otpStore.get(phone);
  if (!data) throw new Error("OTP không tồn tại");
  if (Date.now() > data.expires) throw new Error("OTP hết hạn");
  if (data.otp !== otp) throw new Error("OTP không đúng");

  otpStore.delete(phone);

  const db = await getDB();
  const localPhone = normalizeVnPhone(phone);

  // kiểm tra tồn tại
  const exists = await phoneExists(db, localPhone);

  // nếu chưa có → tạo tài khoản (REGISTER FLOW)
  if (!exists) {
    const result = await db.request()
      .input("sodienthoai", sql.NVarChar(10), localPhone)
      .output("ret", sql.Bit)
      .execute("dbo.sp_TaoTaiKhoan");

    if (!result.output.ret) {
      throw new Error("Tạo tài khoản thất bại");
    }
  }

  // lấy user
  const user = await db.request()
    .input("sdt", sql.NVarChar(10), localPhone)
    .query(`
      SELECT 
        TK.TaiKhoan_ID,
        TK.SoDienThoai,
        TK.LaAdmin,
        ND.NguoiDung_ID,
        ND.TenND
      FROM TaiKhoan TK
      JOIN NguoiDung ND 
        ON TK.NguoiDung_ID = ND.NguoiDung_ID
      WHERE TK.SoDienThoai = @sdt
    `);
  const payload = {
  NguoiDung_ID: user.recordset[0].NguoiDung_ID,
  SoDienThoai: user.recordset[0].SoDienThoai,
};

const token = jwt.sign(
  payload,
  process.env.JWT_SECRET || "my_secret_key",
  { expiresIn: "7d" }
);
  return {
    success: true,
    message: "Xác thực thành công",
    user: user.recordset[0],
    token,
  };

}
