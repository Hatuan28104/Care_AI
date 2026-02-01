import sql from "mssql";
import { getDB } from "../../db.js";
export async function updateProfile(data) {
  const {
    nguoiDungId,
    tenND,
    ngaySinh,
    gioiTinh,
    chieuCao,
    canNang,
    email,
    diaChi,
  } = data;

  const errors = {};

  // ===== ID =====
  if (!nguoiDungId) {
    errors.nguoiDungId = "Thiếu NguoiDung_ID";
  }

  // ===== TÊN =====
  if (!tenND || tenND.trim() === "") {
    errors.tenND = "Tên người dùng là bắt buộc";
  } else if (!/^[A-Za-zÀ-ỹ\s]+$/.test(tenND)) {
    errors.tenND = "Tên không được chứa số hoặc ký tự đặc biệt";
  }

  // ===== NGÀY SINH =====
  let dob;
  if (!ngaySinh) {
    errors.ngaySinh = "Ngày sinh là bắt buộc";
  } else {
    dob = new Date(ngaySinh);
    if (isNaN(dob.getTime())) {
      errors.ngaySinh = "Ngày sinh không hợp lệ";
    } else {
      const today = new Date();
      let age = today.getFullYear() - dob.getFullYear();
      if (
        today.getMonth() < dob.getMonth() ||
        (today.getMonth() === dob.getMonth() &&
          today.getDate() < dob.getDate())
      ) {
        age--;
      }
      if (age < 16) {
        errors.ngaySinh = "Người dùng phải từ 16 tuổi trở lên";
      }
    }
  }

  // ===== GIỚI TÍNH =====
  if (gioiTinh == null) {
    errors.gioiTinh = "Giới tính là bắt buộc";
  } else if (gioiTinh !== 0 && gioiTinh !== 1) {
    errors.gioiTinh = "Giới tính không hợp lệ";
  }

  // ===== CHIỀU CAO =====
  if (chieuCao == null) {
    errors.chieuCao = "Chiều cao là bắt buộc";
  } else if (chieuCao < 50 || chieuCao > 250) {
    errors.chieuCao = "Chiều cao phải trong khoảng 50–250 cm";
  }

  // ===== CÂN NẶNG =====
  if (canNang == null) {
    errors.canNang = "Cân nặng là bắt buộc";
  } else if (canNang < 20 || canNang > 200) {
    errors.canNang = "Cân nặng phải trong khoảng 20–200 kg";
  }

  // ===== EMAIL =====
  if (email && !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
    errors.email = "Email không hợp lệ";
  }

  // ===== ĐỊA CHỈ =====
  if (diaChi && diaChi.length > 255) {
    errors.diaChi = "Địa chỉ quá dài";
  }

  // 🚨 TRẢ LỖI THEO FIELD
  if (Object.keys(errors).length > 0) {
    const err = new Error("Dữ liệu không hợp lệ");
    err.errors = errors;
    throw err;
  }

  // ===== UPDATE DB =====
  const db = await getDB();
  await db.request()
    .input("id", sql.Char(12), nguoiDungId)
    .input("ten", sql.NVarChar(100), tenND)
    .input("ngaySinh", sql.Date, dob)
    .input("gioiTinh", sql.Bit, gioiTinh)
    .input("chieuCao", sql.Decimal(5,2), chieuCao)
    .input("canNang", sql.Decimal(5,2), canNang)
    .input("email", sql.NVarChar(255), email ?? null)
    .input("diaChi", sql.NVarChar(255), diaChi ?? null)
    .query(`
      UPDATE NguoiDung
      SET TenND=@ten, NgaySinh=@ngaySinh, GioiTinh=@gioiTinh,
          ChieuCao=@chieuCao, CanNang=@canNang,
          Email=@email, DiaChi=@diaChi
      WHERE NguoiDung_ID=@id
    `);

  return true;
}
