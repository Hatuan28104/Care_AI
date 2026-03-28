import { getDB } from "../config/db.js";

/* =========================
   DANH SÁCH NGƯỜI GIÁM HỘ CỦA TÔI
========================= */
export async function getMyGuardians(userId) {
  const db = getDB();

  const { data, error } = await db
    .from("quanhegiamho")
    .select(`
      quanhegiamho_id,
      ngaybatdau,
      nguoidung:nguoigiamho_id (
        nguoidung_id,
        tennd,
        avatarurl
      )
    `)
    .eq("nguoiduocgiamho_id", userId)
    .eq("daxoa", false);

  if (error) throw error;

  return data;
}
/* =========================
   DANH SÁCH NGƯỜI TÔI GIÁM HỘ
========================= */
export async function getMyDependents(userId) {
  const db = getDB();

  const { data, error } = await db
    .from("quanhegiamho")
    .select(`
      quanhegiamho_id,
      ngaybatdau,
      nguoidung:nguoiduocgiamho_id (
        nguoidung_id,
        tennd,
        avatarurl
      )
    `)
    .eq("nguoigiamho_id", userId)
    .eq("daxoa", false);

  if (error) throw error;

  return data;
}
/* =========================
   KẾT THÚC QUAN HỆ
========================= */
export async function endRelationship(qhId) {
  const db = getDB();

  const { data } = await db
    .from("quanhegiamho")
    .update({
      daxoa: true,
      ngayketthuc: new Date().toISOString(),
    })
    .eq("quanhegiamho_id", qhId)
    .eq("daxoa", false)
    .select();

  if (!data || data.length === 0) {
    throw new Error("Quan hệ không hợp lệ");
  }
}
/* =========================
   PROFILE QUAN HỆ (GIÁM HỘ / PHỤ THUỘC)
========================= */
export async function getRelationshipProfile(qhId, userId) {
  const db = getDB();

  const { data: rel, error } = await db
    .from("quanhegiamho")
    .select(`
      quanhegiamho_id,
      ngaybatdau,
      nguoigiamho:nguoigiamho_id (nguoidung_id, tennd, avatarurl, gioitinh, ngaysinh, taikhoan(sodienthoai)),
      nguoiduocgiamho:nguoiduocgiamho_id (nguoidung_id, tennd, avatarurl, gioitinh, ngaysinh, taikhoan(sodienthoai))
    `)
    .eq("quanhegiamho_id", qhId)
    .eq("daxoa", false)
    .maybeSingle();

  if (error) throw error;
  if (!rel) throw new Error("Không tìm thấy quan hệ");

  // xác định role
  let role = null;
  let targetUserId = null;

  if (rel.nguoiduocgiamho_id === userId) {
    role = "GUARDIAN";
    targetUserId = rel.nguoigiamho_id;
  } else if (rel.nguoigiamho_id === userId) {
    role = "DEPENDENT";
    targetUserId = rel.nguoiduocgiamho_id;
  } else {
    throw new Error("Không có quyền xem");
  }

  // lấy user info
  const { data: user } = await db
    .from("nguoidung")
    .select(`
      nguoidung_id,
      tennd,
      avatarurl,
      gioitinh,
      ngaysinh,
      taikhoan (
        sodienthoai
      )
    `)
    .eq("nguoidung_id", targetUserId)
    .maybeSingle();

  if (!user) throw new Error("Không tìm thấy user");

  return {
    quanhegiamho_id: rel.quanhegiamho_id,
    ngaybatdau: rel.ngaybatdau,
    nguoigiamho_id: rel.nguoigiamho_id,
    nguoiduocgiamho_id: rel.nguoiduocgiamho_id,
    role,
    ...user,
  };
}