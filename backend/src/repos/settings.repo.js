import { getDB } from "../config/db.js";

/* =========================
   GET SETTINGS
========================= */
export async function getSettings(userId) {
  const db = getDB();

  let { data, error } = await db
    .from("caidat")
    .select(`
      thongbao,
      amthanh,
      rung,
      amluong
    `)
    .eq("nguoidung_id", userId)
    .maybeSingle();

  if (error) throw error;

  if (!data) {
    const { error: insertErr } = await db.from("caidat").insert({
      nguoidung_id: userId,
      thongbao: true,
      amthanh: true,
      rung: true,
      amluong: 0.6,
    });
    if (insertErr) throw insertErr;

    data = {
      thongbao: true,
      amthanh: true,
      rung: true,
      amluong: 0.6,
    };
  }

  return {
    thongbao: data.thongbao === true,
    amthanh: data.amthanh === true,
    rung: data.rung === true,
    amluong: data.amluong ?? 0.6,
  };
}
/* =========================
   UPDATE 1 FIELD
========================= */
export async function updateSetting(userId, key, value) {
  const db = getDB();

  const allowedFields = [
    "thongbao",
    "amthanh",
    "rung",
    "amluong"
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
    .from("caidat")
    .upsert(payload, {
      onConflict: ["nguoidung_id"],
    });

  if (error) throw error;
}