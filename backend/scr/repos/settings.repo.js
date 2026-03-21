import { getDB } from "../config/db.js";

/* =========================
   GET SETTINGS
========================= */
export async function getSettings(userId) {
  const db = getDB();

  let { data, error } = await db
    .from("appsettings")
    .select(`
      notificationon,
      healthalerton,
      syncdataon,
      soundon,
      vibrationon,
      volume
    `)
    .eq("nguoidung_id", userId)
    .maybeSingle();

  if (error) throw error;

  if (!data) {
    const { error: insertErr } = await db.from("appsettings").insert({
      nguoidung_id: userId,
      notificationon: true,
      healthalerton: true,
      syncdataon: true,
      soundon: true,
      vibrationon: true,
      volume: 0.6,
    });
    if (insertErr) throw insertErr;

    data = {
      notificationon: true,
      healthalerton: true,
      syncdataon: true,
      soundon: true,
      vibrationon: true,
      volume: 0.6,
    };
  }

  return {
    notificationOn: data.notificationon === true,
    healthAlertOn: data.healthalerton === true,
    syncDataOn: data.syncdataon === true,
    soundOn: data.soundon === true,
    vibrationOn: data.vibrationon === true,
    volume: data.volume ?? 0.6,
  };
}
/* =========================
   UPDATE 1 FIELD
========================= */
export async function updateSetting(userId, key, value) {
  const db = getDB();

  const allowedFields = [
    "notificationon",
    "healthalerton",
    "syncdataon",
    "soundon",
    "vibrationon",
    "volume"
  ];

  const field = key.toLowerCase();

  if (!allowedFields.includes(field)) {
    throw new Error("Invalid setting key");
  }

  const payload = {
    nguoidung_id: userId,
    [field]: value,
  };

  const { error } = await db
    .from("appsettings")
    .upsert(payload, {
      onConflict: ["nguoidung_id"],
    });

  if (error) throw error;
}