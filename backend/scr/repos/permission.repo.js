import sql from "mssql";
import { getDB } from "../config/db.js";

/* =========================
   DANH SÁCH QUYỀN
========================= */
export async function getAllPermissions() {
  const db = await getDB();

  const rs = await db.request().query(`
    SELECT Quyen_ID, TenQuyen
    FROM QuyenChiaSe
  `);

  return rs.recordset;
}

/* =========================
   QUYỀN ĐÃ CẤU HÌNH THEO QUAN HỆ
========================= */
export async function getPermissionConfigs(quanHeId) {
  const db = await getDB();

  const rs = await db.request()
    .input("qh", sql.Char(12), quanHeId)
    .query(`
      SELECT 
        Q.Quyen_ID,
        Q.TenQuyen,
        ISNULL(CH.DaKichHoat, 0) AS DaKichHoat
      FROM QuyenChiaSe Q
      LEFT JOIN CauHinhDuLieu CH
        ON Q.Quyen_ID = CH.Quyen_ID
       AND CH.QuanHeGiamHo_ID = @qh
    `);

  return rs.recordset;
}

/* =========================
   BẬT / TẮT QUYỀN
========================= */
export async function savePermissionConfig(quanHeId, quyenId, active) {
  const db = await getDB();

  await db.request()
    .input("qh", sql.Char(12), quanHeId)
    .input("q", sql.Char(12), quyenId)
    .input("a", sql.Bit, active)
    .query(`
      MERGE CauHinhDuLieu AS T
      USING (SELECT @qh AS QH, @q AS Q) AS S
      ON T.QuanHeGiamHo_ID = S.QH
     AND T.Quyen_ID = S.Q
      WHEN MATCHED THEN
        UPDATE SET 
          DaKichHoat = @a,
          ThoiGianCH = GETDATE()
      WHEN NOT MATCHED THEN
        INSERT (
          CauHinhDuLieu_ID,
          QuanHeGiamHo_ID,
          Quyen_ID,
          DaKichHoat,
          ThoiGianCH
        )
        VALUES (
          'CH' + RIGHT(NEWID(),10),
          @qh,
          @q,
          @a,
          GETDATE()
        );
    `);
}
