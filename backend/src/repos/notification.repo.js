import admin from "firebase-admin";
import { getDB } from "../config/db.js";

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
function mapSelfTitle(level) {
  switch (level) {
    case 3:
      return "Bạn đang ở trạng thái nguy hiểm";
    case 2:
      return "Bạn đang gặp áp lực";
    default:
      return "Bạn có dấu hiệu buồn";
  }
}
/* =========================
   INSERT NOTIFICATION
========================= */
async function insertNoti(db, userId, title, body, type = 'ALERT') {
  const id = `NT${Date.now().toString().slice(-9)}${Math.floor(
    Math.random() * 1000
  )
    .toString()
    .padStart(3, "0")}`;

  const { error } = await db
    .from("notifications")
    .insert({
      notification_id: id,
      nguoidung_id: userId,
      tieude: title,
      noidung: body,
      type: type,
      thoigian: new Date().toISOString(),
      dadoc: false,
    });

  if (error) throw error;
}

/* =========================
   SEND FCM HELPER
========================= */
async function sendFCM(db, token, title, body) {
  try {
    await admin.messaging().send({
      token,
      notification: { title, body },
    });
  } catch (err) {
    if (err.errorInfo?.code === "messaging/registration-token-not-registered") {
      console.log("Token chết → xoá:", token);

      await db
        .from("fcmtokens")
        .delete()
        .eq("token", token);
    }
  }
}

/* =========================
   SEND NOTIFICATION (USER + GUARDIAN)
========================= */
export async function sendNotification(userId, title, body, level = 1, type = 'ALERT', titleGuardian = null) {
  try {
    const db = getDB();

    // ===== 1. CHECK SETTING =====
    const { data: setting, error: settingErr } = await db
      .from("caidat")
      .select("thongbao")
      .eq("nguoidung_id", userId)
      .maybeSingle();

    if (settingErr) {
      console.log("Bỏ qua check caidat:", settingErr.message);
    }

    if (!settingErr && setting && setting.thongbao === false) {
      console.log("🔕 User tắt thông báo");
      return;
    }

    // ===== 2. GET USER NAME =====
    const { data: user } = await db
      .from("nguoidung")
      .select("tennd")
      .eq("nguoidung_id", userId)
      .single();

    const userName = user?.tennd || userId;

    // ===== 3. SEND TO USER =====
    const { data: userTokens } = await db
      .from("fcmtokens")
      .select("token")
      .eq("nguoidung_id", userId);

    const selfTitle = (type === 'ALERT') ? mapSelfTitle(level) : (title || 'Thông báo');

    for (let t of userTokens || []) {
      await sendFCM(db, t.token, selfTitle, body);
    }

    await insertNoti(db, userId, selfTitle, body, type);
    // ===== 4. GET GUARDIANS =====
    const { data: relations } = await db
      .from("quanhegiamho")
      .select("nguoigiamho_id, nguoiduocgiamho_id")
      .or(`nguoiduocgiamho_id.eq.${userId},nguoigiamho_id.eq.${userId}`)
      .eq("daxoa", false);

    const guardianIds = Array.from(
      new Set(
        (relations || [])
          .map(r =>
            r.nguoiduocgiamho_id === userId
              ? r.nguoigiamho_id
              : r.nguoiduocgiamho_id
          )
          .filter(id => !!id && id !== userId)
      )
    );

    // ===== 5. SEND TO GUARDIANS =====
    for (let guardianId of guardianIds) {

      const gTitle = (type === 'ALERT') ? mapGuardianTitle(level) : (titleGuardian || title || 'Thông báo');
      const gBody = `${userName}: "${body}"`;

      const { data: tokens } = await db
        .from("fcmtokens")
        .select("token")
        .eq("nguoidung_id", guardianId);

      for (let t of tokens || []) {
        await sendFCM(db, t.token, gTitle, gBody);
      }

      await insertNoti(db, guardianId, gTitle, gBody, type);
    }

  } catch (err) {
    console.error("sendNotification error:", err);
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
  const db = getDB();

  const { error } = await db
    .from("notifications")
    .update({ dadoc: true })
    .eq("notification_id", notificationId)
    .eq("nguoidung_id", userId);

  if (error) throw error;
}
export async function deleteNotification(notificationId, userId) {
  const db = getDB();

  const { error } = await db
    .from("notifications")
    .delete()
    .eq("notification_id", notificationId)
    .eq("nguoidung_id", userId);

  if (error) throw error;
}
export async function getAlerts(userId) {
  const db = getDB();

  const { data, error } = await db
    .from("notifications")
    .select(`
      notification_id,
      tieude,
      noidung,
      thoigian,
      dadoc,
      type 
    `)
    .eq("nguoidung_id", userId)
    .order("thoigian", { ascending: false });

  if (error) throw error;

  return (data || []).map(item => ({
    ...item,
    thoigian: item.thoigian ? new Date(item.thoigian).toISOString() : ""
  }));
}
export async function getAdminAlerts() {
  const db = getDB();

  const { data, error } = await db
    .from("canhbaotinnhan")
    .select(`
      canhbaotinnhan_id,
      motacanhbao,
      thoigiancanhbao
    `)
    .eq("daxoa", false)
    .order("thoigiancanhbao", { ascending: false });

  if (error) throw error;

  return (data || []).map(item => ({
    ...item,
    thoigian: item.thoigiancanhbao ? new Date(item.thoigiancanhbao).toISOString() : ""
  }));
}