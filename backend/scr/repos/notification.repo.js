import admin from "firebase-admin";
import { getDB } from "../config/db.js";
import sql from "mssql";

function mapGuardianTitle(level) {
  switch (level) {
    case 3:
      return "Người thân có dấu hiệu nguy hiểm";
    case 2:
      return "Người thân đang gặp áp lực";
    default:
      return "Người thân có dấu hiệu buồn";
  }
}
/* =========================
   INSERT NOTIFICATION
========================= */
async function insertNoti(db, userId, title, body) {
  await db.request()
    .input("uid", sql.Char(12), userId)
    .input("title", sql.NVarChar(255), title)
    .input("body", sql.NVarChar(sql.MAX), body)
    .query(`
      INSERT INTO Notifications (
        NguoiDung_ID,
        TieuDe,
        NoiDung,
        ThoiGian,
        DaDoc
      )
      VALUES (
        @uid,
        @title,
        @body,
        GETDATE(),
        0
      )
    `);
}

/* =========================
   SEND FCM HELPER
========================= */
async function sendFCM(db, token, title, body) {
  try {
    console.log("Sending FCM to:", token);

    const res = await admin.messaging().send({
      token,
      notification: { title, body },
    });


  } catch (err) {
    if (err.errorInfo?.code === 'messaging/registration-token-not-registered') {
      console.log("Token chết → xoá khỏi DB:", token);

      await db.request()
        .input("token", sql.NVarChar(255), token)
        .query(`DELETE FROM FcmTokens WHERE Token = @token`);
    }

  }
}

/* =========================
   SEND NOTIFICATION (USER + GUARDIAN)
========================= */
export async function sendNotification(userId, title, body, level = 1) {
  try {
    const db = await getDB();

    // ===== 1. CHECK SETTING =====
    const setting = await db.request()
      .input("userId", sql.Char(12), userId)
      .query(`
        SELECT NotificationOn
        FROM AppSettings
        WHERE NguoiDung_ID = @userId
      `);

    if (
      setting.recordset.length > 0 &&
      setting.recordset[0].NotificationOn === false
    ) {
      console.log("🔕 User tắt thông báo");
      return;
    }

    // ===== 2. GET USER NAME =====
    const userRs = await db.request()
      .input("userId", sql.Char(12), userId)
      .query(`
        SELECT TenND
        FROM NguoiDung
        WHERE NguoiDung_ID = @userId
      `);

    const userName = userRs.recordset[0]?.TenND || userId;

    // ===== 3. SEND TO USER =====
    const userTokens = await db.request()
      .input("userId", sql.Char(12), userId)
      .query(`
        SELECT Token FROM FcmTokens
        WHERE NguoiDung_ID = @userId
      `);

    for (let t of userTokens.recordset) {
      await sendFCM(db, t.Token, title, body);
    }

    await insertNoti(db, userId, title, body);

    // ===== 4. GET GUARDIANS =====
    const guardians = await db.request()
      .input("userId", sql.Char(12), userId)
      .query(`
        SELECT NguoiGiamHo_ID
        FROM QuanHeGiamHo
        WHERE NguoiDuocGiamHo_ID = @userId
          AND DaXoa = 0
      `);

    // ===== 5. SEND TO GUARDIANS =====
    for (let g of guardians.recordset) {
      const guardianId = g.NguoiGiamHo_ID;

      const gTitle = mapGuardianTitle(level);
      const gBody = `${userName}: "${body}"`;

      const tokens = await db.request()
        .input("gid", sql.Char(12), guardianId)
        .query(`
          SELECT Token FROM FcmTokens
          WHERE NguoiDung_ID = @gid
        `);

      for (let t of tokens.recordset) {
        await sendFCM(db, t.Token, gTitle, gBody);
      }

      await insertNoti(db, guardianId, gTitle, gBody);
    }


  } catch (err) {
  }
}

/* =========================
   BROADCAST
========================= */
export async function sendToAll(title, body) {
  await admin.messaging().send({
    topic: "all_users",
    notification: { title, body },
  });

  console.log("Broadcast sent");
}
export async function markAsRead(notificationId, userId) {
  const db = await getDB();

  await db.request()
    .input("id", sql.Char(12), notificationId)
    .input("uid", sql.Char(12), userId)
    .query(`
      UPDATE Notifications
      SET DaDoc = 1
      WHERE Notification_ID = @id
        AND NguoiDung_ID = @uid
    `);
}
export async function deleteNotification(notificationId, userId) {
  const db = await getDB();

  await db.request()
    .input("id", sql.Char(12), notificationId)
    .input("uid", sql.Char(12), userId)
    .query(`
      DELETE FROM Notifications
      WHERE Notification_ID = @id
        AND NguoiDung_ID = @uid
    `);
}
export async function getAlerts(userId) {
  const db = await getDB();

  const result = await db.request()
    .input("uid", sql.Char(12), userId)
    .query(`
      SELECT 
        Notification_ID,
        TieuDe,
        NoiDung,
        ThoiGian,
        DaDoc
      FROM Notifications
      WHERE NguoiDung_ID = @uid
      ORDER BY ThoiGian DESC
    `);

  return result.recordset;
}
