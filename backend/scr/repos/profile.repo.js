import { getDB } from "../config/db.js";

/* =========================
   HELPERS
========================= */
function normalizeGender(value) {
  const num = Number(value);
  return [0, 1].includes(num) ? num : null;
}

function formatDateToPostgres(date) {
  return date.toISOString().split("T")[0];
}

function validateEmail(email) {
  if (!email) return null;

  const emailTrim = email.trim();
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  if (!regex.test(emailTrim)) return "Email không hợp lệ";
  if (emailTrim.length > 255) return "Email không được vượt quá 255 ký tự";

  return null;
}

function validateName(name) {
  if (!name || name.trim().length === 0) {
    return "Họ tên là bắt buộc";
  }

  if (name.length > 100) {
    return "Họ tên không được vượt quá 100 ký tự";
  }

  const regex = /^[A-Za-zÀ-ỹ\s'-]+$/;

  if (!regex.test(name)) {
    return "Họ tên không hợp lệ";
  }

  return null;
}

/* =========================
   UPDATE PROFILE
========================= */
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
    avatarUrl,
  } = data;

  const errors = {};

  // ===== ID =====
  if (!nguoiDungId) {
    errors.nguoiDungId = "Thiếu NguoiDung_ID";
  }

  // ===== NAME =====
  const nameErr = validateName(tenND);
  if (nameErr) errors.tenND = nameErr;

  // ===== DOB =====
  let dob = null;
  if (!ngaySinh) {
    errors.ngaySinh = "Ngày sinh là bắt buộc";
  } else {
    dob = new Date(ngaySinh);
    if (isNaN(dob.getTime())) {
      errors.ngaySinh = "Ngày sinh không hợp lệ";
    }
  }

  // ===== GENDER =====
  const gender = normalizeGender(gioiTinh);
  if (gender === null) {
    errors.gioiTinh = "Giới tính không hợp lệ";
  }

  // ===== HEIGHT =====
  const height = Number(chieuCao);
  if (isNaN(height)) {
    errors.chieuCao = "Chiều cao phải là số";
  } else if (height <= 50 || height > 300) {
    errors.chieuCao = "Chiều cao không hợp lệ";
  }

  // ===== WEIGHT =====
  const weight = Number(canNang);
  if (isNaN(weight)) {
    errors.canNang = "Cân nặng phải là số";
  } else if (weight <= 20 || weight > 200) {
    errors.canNang = "Cân nặng không hợp lệ";
  }

  // ===== EMAIL =====
  const emailErr = validateEmail(email);
  if (emailErr) errors.email = emailErr;

  // ===== ADDRESS =====
  let diaChiClean = null;
  if (diaChi) {
    diaChiClean = diaChi.trim();

    if (diaChiClean.length > 255) {
      errors.diaChi = "Địa chỉ không được vượt quá 255 ký tự";
    }

    const regex = /^[0-9a-zA-ZÀ-ỹ\s,.\-\/]+$/;
    if (!regex.test(diaChiClean)) {
      errors.diaChi = "Địa chỉ không hợp lệ";
    }
  }

  // ===== CHECK ERROR =====
  if (Object.keys(errors).length > 0) {
    const err = new Error("Dữ liệu không hợp lệ");
    err.errors = errors;
    throw err;
  }

  // ===== UPDATE =====
const updateData = {
  tennd: tenND.trim(),
  ngaysinh: formatDateToPostgres(dob),
  gioitinh: gender === 1,
  chieucao: height,
  cannang: weight,
  email: email?.trim() || null,
  diachi: diaChiClean || null,
};

if (avatarUrl !== undefined) {
  updateData.avatarurl = avatarUrl;
}

const { data: updated, error } = await getDB()
  .from("nguoidung")
  .update(updateData)
  .eq("nguoidung_id", nguoiDungId)
  .select();
  return true;
}

/* =========================
   GET ALL USERS
========================= */
export async function getAllUsers() {
const { data, error } = await getDB()
  .from("nguoidung")
  .select(`
    nguoidung_id,
    tennd,
    ngaysinh,
    taikhoan (
      sodienthoai,
      ngaytao
    )
  `)
    .order("nguoidung_id", { ascending: true });

  if (error) throw error;

  return data.map((u) => ({
    nguoiDungId: u.nguoidung_id,
    tenND: u.tennd,
    ngaySinh: u.ngaysinh,
soDienThoai: u.taikhoan?.[0]?.sodienthoai ?? null,
ngayTao: u.taikhoan?.[0]?.ngaytao ?? null,
  }));
}

/* =========================
   GET PROFILE
========================= */
export async function getProfileById(nguoiDungId) {
  const { data, error } = await getDB()
    .from("nguoidung")
    .select(`
      nguoidung_id,
      tennd,
      ngaysinh,
      gioitinh,
      chieucao,
      cannang,
      email,
      diachi,
      avatarurl,
      taikhoan:taikhoan!nguoidung_id (
        sodienthoai,
        ngaytao
      )
    `)
    .eq("nguoidung_id", nguoiDungId)
    .maybeSingle();

  if (error) throw error;
  if (!data) return null;

  return {
    nguoiDungId: data.nguoidung_id,
    tenND: data.tennd,
    ngaySinh: data.ngaysinh,
    gioiTinh: data.gioitinh,
    chieuCao: data.chieucao,
    canNang: data.cannang,
    email: data.email,
    diaChi: data.diachi,
    avatarUrl: data.avatarurl,

    soDienThoai: data.taikhoan?.[0]?.sodienthoai ?? null,
    ngayTao: data.taikhoan?.[0]?.ngaytao ?? null,
  };
}

/* =========================
   DELETE USER
========================= */
export async function deleteUser(userId) {
  const db = getDB();

  // delete TaiKhoan trước
  const { error: err1 } = await db
  .from("taikhoan")
  .delete()
  .eq("nguoidung_id", userId);

  if (err1) throw err1;

  // delete NguoiDung
  const { data, error: err2 } = await db
    .from("nguoidung")
    .delete()
    .eq("nguoidung_id", userId)
    .select();

  if (err2) throw err2;

  if (!data || data.length === 0) {
    throw new Error("Không tìm thấy người dùng để xoá");
  }

  return true;
}
export async function getUserStats() {
  const db = getDB();

  const { data, error } = await db
    .from("taikhoan")
    .select("ngaytao");

  if (error) throw error;

  return data;
}