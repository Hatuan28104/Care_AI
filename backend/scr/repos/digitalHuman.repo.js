import { getDB } from "../../db.js";

export async function getAllDigitalHuman() {
  const pool = await getDB();

  const result = await pool.request().query(`
    SELECT 
        DigitalHuman_ID,
        TenDigitalHuman,
        ImageUrl,
        SystemPrompt
    FROM DigitalHuman
    WHERE DangHoatDong = 1
  `);

  return result.recordset;
}
