import sql from "mssql";
import { getDB } from "../../db.js";
export async function updateProfile(data) {
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

  // ===== ID =====
  if (!nguoiDungId) {
    errors.nguoiDungId = "Thiếu NguoiDung_ID";
  }

  // ===== HỌ TÊN =====
  if (!tenND || tenND.trim().length === 0) {
    errors.tenND = "Họ tên là bắt buộc";
  } else if (tenND.length > 100) {
    errors.tenND = "Họ tên không được vượt quá 100 ký tự";
  } else {
    const nameRegex = /^[A-Za-zÀ-ỹ\s]+$/;

    if (!nameRegex.test(tenND)) {
      errors.tenND = "Họ tên không được chứa số hoặc ký tự đặc biệt";
    }
  }

  // ===== NGÀY SINH =====
  let dob = null;
  if (!ngaySinh) {
    errors.ngaySinh = "Ngày sinh là bắt buộc";
  } else {
    dob = new Date(ngaySinh);
    if (isNaN(dob.getTime())) {
      errors.ngaySinh = "Ngày sinh không hợp lệ";
    }
  }

  // ===== GIỚI TÍNH =====
  if (gioiTinh == null) {
    errors.gioiTinh = "Giới tính là bắt buộc";
  } else if (gioiTinh !== 0 && gioiTinh !== 1) {
    errors.gioiTinh = "Giới tính không hợp lệ";
  }

  // ===== CHIỀU CAO =====
  const height = Number(chieuCao);
  if (!chieuCao || isNaN(height)) {
    errors.chieuCao = "Chiều cao phải là số";
  } else if (height <= 0 || height > 300) {
    errors.chieuCao = "Chiều cao không hợp lệ";
  }

  // ===== CÂN NẶNG =====
  const weight = Number(canNang);
  if (!canNang || isNaN(weight)) {
    errors.canNang = "Cân nặng phải là số";
  } else if (weight <= 0 || weight > 200) {
    errors.canNang = "Cân nặng không hợp lệ";
  }

  // ===== EMAIL (không bắt buộc) =====
  if (email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!emailRegex.test(email)) {
      errors.email = "Email không hợp lệ";
    }

    if (email.length > 255) {
      errors.email = "Email không được vượt quá 255 ký tự";
    }
  }

  // ===== ĐỊA CHỈ (không bắt buộc) =====
  if (diaChi) {
    if (diaChi.length > 255) {
      errors.diaChi = "Địa chỉ không được vượt quá 255 ký tự";
    }

    const addressRegex = /^[0-9a-zA-ZÀ-ỹ\s,.\-\/]+$/;

    if (!addressRegex.test(diaChi)) {
      errors.diaChi = "Địa chỉ không được chứa ký tự đặc biệt";
    }
  }

  // ===== CHECK ERROR =====
  if (Object.keys(errors).length > 0) {
    const err = new Error("Dữ liệu không hợp lệ");
    err.errors = errors;
    throw err;
  }

  // ===== UPDATE DB =====
  const db = await getDB();
  const result = await db.request()
    .input("id", sql.NVarChar(50), nguoiDungId)
    .input("ten", sql.NVarChar(100), tenND)
    .input("ngaySinh", sql.Date, dob)
    .input("gioiTinh", sql.Bit, gioiTinh === 1)
    .input("chieuCao", sql.Decimal(5, 2), height)
    .input("canNang", sql.Decimal(5, 2), weight)
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
    throw new Error("Không tìm thấy người dùng để cập nhật");
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