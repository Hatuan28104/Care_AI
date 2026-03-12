import sql from "mssql";
import { getDB } from "../config/db.js";

/* =========================
   GET SETTINGS
========================= */
export async function getSettings(userId) {
  const db = await getDB();

  const result = await db.request()
    .input("userId", sql.Char(12), userId)
    .query(`
      SELECT 
        NotificationOn,
        HealthAlertOn,
        SyncDataOn,
        SoundOn,
        VibrationOn,
        Volume
      FROM AppSettings
      WHERE NguoiDung_ID = @userId
    `);

  if (result.recordset.length === 0) {
    return {
      notificationOn: true,
      healthAlertOn: true,
      syncDataOn: true,
      soundOn: true,
      vibrationOn: true,
      volume: 0.6
    };
  }

  const row = result.recordset[0];

  return {
    notificationOn: row.NotificationOn,
    healthAlertOn: row.HealthAlertOn,
    syncDataOn: row.SyncDataOn,
    soundOn: row.SoundOn,
    vibrationOn: row.VibrationOn,
    volume: row.Volume
  };
}

/* =========================
   UPDATE 1 FIELD
========================= */
export async function updateSetting(userId, key, value) {
  const db = await getDB();

  const allowedFields = [
    "NotificationOn",
    "HealthAlertOn",
    "SyncDataOn",
    "SoundOn",
    "VibrationOn",
    "Volume"
  ];

  if (!allowedFields.includes(key)) {
    throw new Error("Invalid setting key");
  }

  await db.request()
    .input("userId", sql.Char(12), userId)
    .input("value", key === "Volume" ? sql.Float : sql.Bit, value)
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