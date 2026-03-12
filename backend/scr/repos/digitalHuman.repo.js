import { getDB } from "../config/db.js";

/* =========================
   GET ALL DIGITAL HUMAN
========================= */
export async function getAllDigitalHuman() {
  const pool = await getDB();

  const result = await pool.request().query(`
    SELECT 
        DigitalHuman_ID,
        TenDigitalHuman,
        ImageUrl,
        SystemPrompt,
        GioiTinh,
        NgheNghiep_ID,
        NgoaiHinh
    FROM DigitalHuman
  `);

  return result.recordset;
}

/* =========================
   GET DIGITAL HUMAN BY ID
========================= */
export async function getDigitalHumanById(id) {
  const pool = await getDB();

  const result = await pool
    .request()
    .input("id", id)
    .query(`
      SELECT 
        DigitalHuman_ID,
        TenDigitalHuman,
        ImageUrl,
        SystemPrompt,
        GioiTinh,
        NgheNghiep_ID,
        NgoaiHinh
      FROM DigitalHuman
      WHERE DigitalHuman_ID = @id
    `);

  return result.recordset[0];
}

/* =========================
   CREATE DIGITAL HUMAN
========================= */
export async function createDigitalHuman(data) {
  const pool = await getDB();

  await pool
    .request()
    .input("id", data.id)
    .input("name", data.name)
    .input("image", data.image)
    .input("prompt", data.prompt)
    .input("job", data.jobId)
    .input("gender", data.gender)
    .input("appearance", data.appearance)
    .query(`
      INSERT INTO DigitalHuman
      (
        DigitalHuman_ID,
        TenDigitalHuman,
        ImageUrl,
        SystemPrompt,
        NgheNghiep_ID,
        GioiTinh,
        NgoaiHinh
      )
      VALUES
      (
        @id,
        @name,
        @image,
        @prompt,
        @job,
        @gender,
        @appearance
      )
    `);

  return { message: "Tạo Digital Human thành công" };
}

/* =========================
   UPDATE DIGITAL HUMAN
========================= */
export async function updateDigitalHuman(id, data) {
  const pool = await getDB();

  await pool
    .request()
    .input("id", id)
    .input("name", data.name)
    .input("image", data.image)
    .input("prompt", data.prompt)
    .input("job", data.jobId)
    .input("gender", data.gender)
    .input("appearance", data.appearance)
    .query(`
      UPDATE DigitalHuman
      SET
        TenDigitalHuman = @name,
        ImageUrl = @image,
        SystemPrompt = @prompt,
        NgheNghiep_ID = @job,
        GioiTinh = @gender,
        NgoaiHinh = @appearance
      WHERE DigitalHuman_ID = @id
    `);

  return { message: "Cập nhật Digital Human thành công" };
}

/* =========================
   DELETE DIGITAL HUMAN
========================= */
export async function deleteDigitalHuman(id) {
  const pool = await getDB();

  await pool
    .request()
    .input("id", id)
    .query(`
      DELETE FROM DigitalHuman
      WHERE DigitalHuman_ID = @id
    `);

  return { message: "Xóa Digital Human thành công" };
}