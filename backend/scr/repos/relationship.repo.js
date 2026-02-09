import sql from "mssql";
import { getDB } from "../../db.js";

/* =========================
   DANH SÁCH NGƯỜI GIÁM HỘ CỦA TÔI
========================= */
export async function getMyGuardians(userId) {
  const db = await getDB();

  const rs = await db.request()
    .input("uid", sql.Char(12), userId)
    .query(`
      SELECT QH.QuanHeGiamHo_ID,QH.NgayBatDau AS NgayBatDau, ND.NguoiDung_ID, ND.TenND, ND.AvatarUrl
      FROM QuanHeGiamHo QH
      JOIN NguoiDung ND ON ND.NguoiDung_ID = QH.NguoiGiamHo_ID
      WHERE QH.NguoiDuocGiamHo_ID = @uid
        AND QH.DaXoa = 0
    `);

  return rs.recordset;
}

/* =========================
   DANH SÁCH NGƯỜI TÔI GIÁM HỘ
========================= */
export async function getMyDependents(userId) {
  const db = await getDB();

  const rs = await db.request()
    .input("uid", sql.Char(12), userId)
    .query(`
      SELECT QH.QuanHeGiamHo_ID,QH.NgayBatDau AS NgayBatDau, ND.NguoiDung_ID, ND.TenND,ND.AvatarUrl
      FROM QuanHeGiamHo QH
      JOIN NguoiDung ND ON ND.NguoiDung_ID = QH.NguoiDuocGiamHo_ID
      WHERE QH.NguoiGiamHo_ID = @uid
        AND QH.DaXoa = 0
    `);

  return rs.recordset;
}

/* =========================
   KẾT THÚC QUAN HỆ
========================= */
export async function endRelationship(qhId) {
  const db = await getDB();

  const rs = await db.request()
    .input("id", sql.Char(12), qhId)
    .query(`
      UPDATE QuanHeGiamHo
      SET DaXoa = 1,
          NgayKetThuc = GETDATE()
      WHERE QuanHeGiamHo_ID = @id
        AND DaXoa = 0
    `);

  if (rs.rowsAffected[0] === 0) {
    throw new Error("Quan hệ không hợp lệ");
  }
}
/* =========================
   PROFILE QUAN HỆ (GIÁM HỘ / PHỤ THUỘC)
========================= */
export async function getRelationshipProfile(qhId, userId) {
  const db = await getDB();

  const rs = await db.request()
    .input("qhId", sql.Char(12), qhId)
    .input("uid", sql.Char(12), userId)
    .query(`
      SELECT
        QH.QuanHeGiamHo_ID,
        QH.NgayBatDau,

        -- xác định vai trò
        CASE 
          WHEN QH.NguoiDuocGiamHo_ID = @uid THEN 'GUARDIAN'
          WHEN QH.NguoiGiamHo_ID = @uid THEN 'DEPENDENT'
        END AS VaiTro,

        ND.NguoiDung_ID,
        ND.TenND,
        ND.AvatarUrl,
        ND.GioiTinh,
        ND.NgaySinh,
        TK.SoDienThoai
      FROM QuanHeGiamHo QH

      -- JOIN ĐÚNG NGƯỜI CẦN HIỂN THỊ
      JOIN NguoiDung ND
        ON ND.NguoiDung_ID = 
          CASE 
            WHEN QH.NguoiDuocGiamHo_ID = @uid 
              THEN QH.NguoiGiamHo_ID
            WHEN QH.NguoiGiamHo_ID = @uid
              THEN QH.NguoiDuocGiamHo_ID
          END

      JOIN TaiKhoan TK
        ON TK.NguoiDung_ID = ND.NguoiDung_ID

      WHERE QH.QuanHeGiamHo_ID = @qhId
        AND QH.DaXoa = 0
        AND (@uid IN (QH.NguoiDuocGiamHo_ID, QH.NguoiGiamHo_ID))
    `);

  if (rs.recordset.length === 0) {
    throw new Error("Không tìm thấy quan hệ hoặc không có quyền xem");
  }

  return rs.recordset[0];
}
