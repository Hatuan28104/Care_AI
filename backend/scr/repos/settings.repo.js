import sql from "mssql";
import { getDB } from "../../db.js";

/* =========================
   GET SETTINGS
========================= */
export async function getSettings(userId) {
  const db = await getDB();

  const result = await db.request()
    .input("userId", sql.Char(12), userId)
    .query(`
      SELECT NotificationOn, HealthAlertOn, SyncDataOn
      FROM AppSettings
      WHERE NguoiDung_ID = @userId
    `);

  if (result.recordset.length === 0) {
    return {
      notificationOn: true,
      healthAlertOn: true,
      syncDataOn: true
    };
  }

  const row = result.recordset[0];

  return {
    notificationOn: row.NotificationOn,
    healthAlertOn: row.HealthAlertOn,
    syncDataOn: row.SyncDataOn
  };
}

/* =========================
   UPDATE 1 FIELD
========================= */
export async function updateSetting(userId, key, value) {
  const db = await getDB();

  // 🔥 Chỉ cho update 3 field hợp lệ (tránh SQL Injection)
  const allowedFields = [
    "notificationOn",
    "healthAlertOn",
    "syncDataOn"
  ];

  if (!allowedFields.includes(key)) {
    throw new Error("Invalid setting key");
  }

  await db.request()
    .input("userId", sql.Char(12), userId)
    .input("value", sql.Bit, value)
    .query(`
      IF EXISTS (SELECT 1 FROM AppSettings WHERE NguoiDung_ID = @userId)
        UPDATE AppSettings
        SET ${key} = @value
        WHERE NguoiDung_ID = @userId
      ELSE
        INSERT INTO AppSettings (NguoiDung_ID, ${key})
        VALUES (@userId, @value)
    `);
}