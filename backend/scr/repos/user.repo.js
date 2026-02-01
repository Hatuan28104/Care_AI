import { getDB } from "../db.js";

export async function getAllUsers() {
  const db = await getDB();
  const result = await db.request().query("SELECT * FROM NguoiDung");
  return result.recordset;
}
