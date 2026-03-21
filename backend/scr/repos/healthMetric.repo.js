import { getDB } from "../config/db.js";

/* =========================
   LẤY DANH SÁCH CHỈ SỐ
========================= */
export async function getAllHealthMetrics() {
  const db = getDB();

  const { data, error } = await db
    .from("loaichisosuckhoe")
    .select("loaichiso_id, tenchiso, donvido, mota, loai");

  if (error) throw error;

  return data;
}

/* =========================
   TẠO CHỈ SỐ MỚI
========================= */
export async function createHealthMetric(data) {
  const db = getDB();

  const { error } = await db.from("loaichisosuckhoe").insert({
    loaichiso_id: data.loaichiso_id,
    tenchiso: data.tenchiso,
    donvido: data.donvido,
    mota: "",
    loai: data.category,
  });

  if (error) throw error;
}

/* =========================
   LƯU DỮ LIỆU SỨC KHỎE
========================= */
export async function saveHealthData(data) {
  const db = getDB();

  const id = Date.now().toString().slice(0, 12);

  const { error } = await db.from("dulieusuckhoe").insert({
    dulieusk_id: id,
    giatri: data.giatri,
    thoigiancapnhat: new Date().toISOString(),
    thietbi_id: data.thietbi_id,
    loaichiso_id: data.loaichiso_id,
  });

  if (error) throw error;
}

/* =========================
   LẤY DỮ LIỆU MỚI NHẤT
========================= */
export async function getLatestHealthData(thietBiId) {
  const db = getDB();

  const { data, error } = await db
    .from("dulieusuckhoe")
    .select(`
      giatri,
      thoigiancapnhat,
      loaichisosuckhoe (
        loaichiso_id,
        tenchiso,
        donvido
      )
    `)
    .eq("thietbi_id", thietBiId)
    .order("thoigiancapnhat", { ascending: false });

  if (error) throw error;

  // lấy record mới nhất mỗi loại
  const map = {};

  for (let item of data) {
    const key = item.loaichisosuckhoe.loaichiso_id;
    if (!map[key]) {
      map[key] = item;
    }
  }

  return Object.values(map);
}

/* =========================
   LỊCH SỬ CHỈ SỐ
========================= */
export async function getHealthHistory(thietBiId, loaiChiSoId) {
  const db = getDB();

  const { data, error } = await db
    .from("dulieusuckhoe")
    .select("giatri, thoigiancapnhat")
    .eq("thietbi_id", thietBiId)
    .eq("loaichiso_id", loaiChiSoId)
    .order("thoigiancapnhat", { ascending: false })
    .limit(50);

  if (error) throw error;

  return data;
}

/* =========================
   REPORT HEALTH DATA
========================= */
export async function getHealthReport(thietBiId, type) {
  const db = getDB();

  let fromDate = new Date();

  if (type === "day") {
    fromDate.setDate(fromDate.getDate());
  } else if (type === "week") {
    fromDate.setDate(fromDate.getDate() - 7);
  } else if (type === "month") {
    fromDate.setDate(fromDate.getDate() - 30);
  }

  const { data, error } = await db
    .from("dulieusuckhoe")
    .select(`
      giatri,
      loaichisosuckhoe (
        tenchiso,
        donvido
      )
    `)
    .eq("thietbi_id", thietBiId)
    .gte("thoigiancapnhat", fromDate.toISOString());

  if (error) throw error;

  // group JS
  const map = {};

  for (let item of data) {
    const key = item.loaichisosuckhoe.tenchiso;

    if (!map[key]) {
      map[key] = {
        tenchiso: key,
        donvido: item.loaichisosuckhoe.donvido,
        total: 0,
        count: 0,
      };
    }

    map[key].total += item.giatri;
    map[key].count++;
  }

  return Object.values(map).map(i => ({
    tenchiso: i.tenchiso,
    donvido: i.donvido,
    giatri: i.total / i.count,
  }));
}