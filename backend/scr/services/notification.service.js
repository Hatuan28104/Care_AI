import admin from "firebase-admin";
import { getDB } from "../config/db.js";
import sql from "mssql";

/* =========================
   SEND NOTIFICATION
========================= */
export async function sendNotification(userId, title, body) {
  const db = await getDB();

  // 1️⃣ Kiểm tra user có bật notification không
  const settingResult = await db.request()
    .input("userId", sql.Char(12), userId)
    .query(`
      SELECT NotificationOn
      FROM AppSettings
      WHERE NguoiDung_ID = @userId
    `);

  if (
    settingResult.recordset.length > 0 &&
    settingResult.recordset[0].NotificationOn === false
  ) {
    console.log("🔕 User đã tắt thông báo");
    return;
  }

  // 2️⃣ Lấy FCM token
  const userResult = await db.request()
    .input("userId", sql.Char(12), userId)
    .query(`
      SELECT FcmToken
      FROM NguoiDung
      WHERE NguoiDung_ID = @userId
    `);

  if (userResult.recordset.length === 0) return;

  const fcmToken = userResult.recordset[0].FcmToken;

  if (!fcmToken) {
    console.log("❌ Không có FCM token");
    return;
  }

  // 3️⃣ Gửi FCM
  await admin.messaging().send({
    token: fcmToken,
    notification: {
      title,
      body,
    },
  });

  console.log("✅ Đã gửi thông báo thành công");
}
export async function sendToAll(title, body) {
  await admin.messaging().send({
    topic: "all_users",
    notification: {
      title,
      body,
    },
  });

  console.log("✅ Gửi broadcast thành công");
}