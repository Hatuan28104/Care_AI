import dotenv from "dotenv";
dotenv.config();

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
    ORDER BY Quyen_ID
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
        Quyen_ID,
        CASE 
          WHEN DaKichHoat = 1 THEN 1
          ELSE 0
        END AS DaKichHoat
      FROM CauHinhDuLieu
      WHERE QuanHeGiamHo_ID = @qh
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
          'CHDL' + RIGHT(REPLACE(NEWID(),'-',''),8),
          @qh,
          @q,
          @a,
          GETDATE()
        );
    `);
}
/* =========================
   LẤY CONVERSATION ĐƯỢC SHARE
========================= */
export async function getSharedConversation(quanHeId) {

  const db = await getDB();

  const rs = await db.request()
    .input("qh", sql.Char(12), quanHeId)
    .query(`
      SELECT
        H.HoiThoai_ID,
        DH.TenDigitalHuman,
        DH.ImageUrl,
        H.LanCuoiTuongTac
      FROM CauHinhDuLieu CH
      JOIN HoiThoai H
        ON H.HoiThoai_ID = CH.Quyen_ID
      JOIN DigitalHuman DH
        ON DH.DigitalHuman_ID = H.DigitalHuman_ID
      WHERE CH.QuanHeGiamHo_ID = @qh
        AND CH.DaKichHoat = 1
        AND CH.Quyen_ID LIKE 'HT%'
      ORDER BY H.LanCuoiTuongTac DESC
    `);

  return rs.recordset;
}