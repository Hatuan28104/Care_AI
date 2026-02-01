import sql from "mssql";
import { getDB } from "../../db.js";

const otpStore = new Map();

export async function requestOtp(phone) {
  const otp = Math.floor(100000 + Math.random() * 900000).toString();

  otpStore.set(phone, {
    otp,
    expires: Date.now() + 2 * 60 * 1000,
  });

  console.log(`📩 OTP cho ${phone}:`, otp);
}

export async function verifyOtp(phone, otp) {
  const data = otpStore.get(phone);
  if (!data) throw new Error("OTP không tồn tại");
  if (Date.now() > data.expires) throw new Error("OTP hết hạn");
  if (data.otp !== otp) throw new Error("OTP không đúng");

  otpStore.delete(phone);

  const db = await getDB();

  // đổi +84xxxx -> 0xxxx
  const localPhone = phone.startsWith("+84")
    ? "0" + phone.slice(3)
    : phone;

  // 1️⃣ Kiểm tra tồn tại
  const exists = await db.request()
    .input("sdt", sql.NVarChar(10), localPhone)
    .query("SELECT 1 FROM TaiKhoan WHERE SoDienThoai = @sdt");

  // 2️⃣ Nếu chưa có → tạo tài khoản
  if (exists.recordset.length === 0) {
    const result = await db.request()
      .input("sodienthoai", sql.NVarChar(10), localPhone)
      .output("ret", sql.Bit)
      .execute("dbo.sp_TaoTaiKhoan");

    if (!result.output.ret) {
      throw new Error("Tạo tài khoản thất bại hoặc SĐT đã tồn tại");
    }
  }

  // 3️⃣ Lấy thông tin user
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

  return {
    success: true,
    message: "Xác thực thành công",
    user: user.recordset[0],
  };
}
