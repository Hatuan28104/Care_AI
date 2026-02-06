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
      SELECT QH.QuanHeGiamHo_ID,QH.NgayBatDau AS NgayBatDau, ND.NguoiDung_ID, ND.TenND
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
      SELECT QH.QuanHeGiamHo_ID,QH.NgayBatDau AS NgayBatDau, ND.NguoiDung_ID, ND.TenND
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
