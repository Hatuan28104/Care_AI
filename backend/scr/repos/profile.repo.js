import sql from "mssql";
import { getDB } from "../../db.js";

export async function updateProfile(data) {
  // destructuring
let {
  nguoiDungId,
  tenND,
  ngaySinh,
  gioiTinh,
  chieuCao,
  canNang,
  email,
  diaChi,
  avatarUrl,
} = data;

// 🔥 parse giới tính
if (gioiTinh === "1") gioiTinh = 1;
if (gioiTinh === "0") gioiTinh = 0;
  const errors = {};

// 🔥 parse ngày sinh (FIX QUAN TRỌNG)
let dob = null;
if (ngaySinh) {
  dob = new Date(ngaySinh);
  if (isNaN(dob.getTime())) {
    errors.ngaySinh = "Ngày sinh không hợp lệ";
  }
}

  if (!nguoiDungId) {
    errors.nguoiDungId = "Thiếu NguoiDung_ID";
  }

  // validate khác giữ nguyên ...

  if (gioiTinh == null) {
    errors.gioiTinh = "Giới tính là bắt buộc";
  } else if (gioiTinh !== 0 && gioiTinh !== 1) {
    errors.gioiTinh = "Giới tính không hợp lệ";
  }

  if (Object.keys(errors).length > 0) {
    const err = new Error("Dữ liệu không hợp lệ");
    err.errors = errors;
    throw err;
  }

  const db = await getDB();
  const result = await db.request()
    .input("id", sql.NVarChar(50), nguoiDungId) // 🔥 FIX 1
    .input("ten", sql.NVarChar(100), tenND)
    .input("ngaySinh", sql.Date, dob)
    .input("gioiTinh", sql.Bit, gioiTinh === 1) // 🔥 FIX 2
.input("chieuCao", sql.Decimal(5, 2), Number(chieuCao))
.input("canNang", sql.Decimal(5, 2), Number(canNang))

    .input("email", sql.NVarChar(255), email ?? null)
    .input("diaChi", sql.NVarChar(255), diaChi ?? null)
    .input("avatarUrl", sql.NVarChar(500), avatarUrl ?? null)
    .query(`
      UPDATE NguoiDung
      SET TenND=@ten,
          NgaySinh=@ngaySinh,
          GioiTinh=@gioiTinh,
          ChieuCao=@chieuCao,
          CanNang=@canNang,
          Email=@email,
          DiaChi=@diaChi,
          AvatarUrl=@avatarUrl
      WHERE NguoiDung_ID=@id
    `);

  if (result.rowsAffected[0] === 0) {
    throw new Error("Không tìm thấy người dùng để cập nhật"); // 🔥 FIX 3
  }

  return true;
}

export async function getProfileById(nguoiDungId) {
  const db = await getDB();

  const result = await db.request()
.input("id", sql.NVarChar(50), nguoiDungId)
    .query(`
      SELECT 
        NguoiDung_ID,
        TenND,
        NgaySinh,
        GioiTinh,
        ChieuCao,
        CanNang,
        Email,
        DiaChi,
        AvatarUrl
      FROM NguoiDung
      WHERE NguoiDung_ID = @id
    `);

  return result.recordset[0] || null;
}
