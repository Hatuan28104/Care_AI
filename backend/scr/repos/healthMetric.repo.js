import { getDB } from "../../db.js";

/* =========================
   LẤY DANH SÁCH CHỈ SỐ
========================= */
export async function getAllHealthMetrics() {
  const pool = await getDB();

  const result = await pool.request().query(`
    SELECT 
        LoaiChiSo_ID,
        TenChiSo,
        DonViDo,
        MoTa,
        Category
    FROM LoaiChiSoSucKhoe
  `);

  return result.recordset;
}


/* =========================
   TẠO CHỈ SỐ MỚI
========================= */
export async function createHealthMetric(data) {

  const pool = await getDB();

  await pool.request()
    .input("LoaiChiSo_ID", data.LoaiChiSo_ID)
    .input("TenChiSo", data.TenChiSo)
    .input("DonViDo", data.DonViDo)
    .input("MoTa", "")
    .input("Category", data.Category)
    .query(`
      INSERT INTO LoaiChiSoSucKhoe
      (LoaiChiSo_ID, TenChiSo, DonViDo, MoTa, Category)
      VALUES
      (@LoaiChiSo_ID, @TenChiSo, @DonViDo, @MoTa, @Category)
    `);
}


/* =========================
   LƯU DỮ LIỆU SỨC KHỎE
========================= */
export async function saveHealthData(data) {

  const pool = await getDB();

  const id = Date.now().toString().slice(0,12);

  await pool.request()
    .input("DuLieuSK_ID", id)
    .input("GiaTri", data.GiaTri)
    .input("ThoiGianCapNhat", new Date())
    .input("ThietBi_ID", data.ThietBi_ID)
    .input("LoaiChiSo_ID", data.LoaiChiSo_ID)
    .query(`
      INSERT INTO DuLieuSucKhoe
      (DuLieuSK_ID, GiaTri, ThoiGianCapNhat, ThietBi_ID, LoaiChiSo_ID)
      VALUES
      (@DuLieuSK_ID, @GiaTri, @ThoiGianCapNhat, @ThietBi_ID, @LoaiChiSo_ID)
    `);
}


/* =========================
   LẤY DỮ LIỆU MỚI NHẤT
========================= */
export async function getLatestHealthData(thietBiId) {

  const pool = await getDB();

  const result = await pool.request()
    .input("ThietBi_ID", thietBiId)
    .query(`
      SELECT 
          l.LoaiChiSo_ID,
          l.TenChiSo,
          l.DonViDo,
          d.GiaTri,
          d.ThoiGianCapNhat
      FROM DuLieuSucKhoe d
      JOIN LoaiChiSoSucKhoe l
        ON d.LoaiChiSo_ID = l.LoaiChiSo_ID
      WHERE d.ThietBi_ID = @ThietBi_ID
      AND d.ThoiGianCapNhat = (
          SELECT MAX(ThoiGianCapNhat)
          FROM DuLieuSucKhoe
          WHERE ThietBi_ID = @ThietBi_ID
          AND LoaiChiSo_ID = d.LoaiChiSo_ID
      )
    `);

  return result.recordset;
}


/* =========================
   LỊCH SỬ CHỈ SỐ
========================= */
export async function getHealthHistory(thietBiId, loaiChiSoId) {

  const pool = await getDB();

  const result = await pool.request()
    .input("ThietBi_ID", thietBiId)
    .input("LoaiChiSo_ID", loaiChiSoId)
    .query(`
      SELECT TOP 50
        GiaTri,
        ThoiGianCapNhat
      FROM DuLieuSucKhoe
      WHERE ThietBi_ID = @ThietBi_ID
      AND LoaiChiSo_ID = @LoaiChiSo_ID
      ORDER BY ThoiGianCapNhat DESC
    `);

  return result.recordset;
}