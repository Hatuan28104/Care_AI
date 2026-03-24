import { getDB } from "../config/db.js";

/* =========================
   HELPER: normalize
========================= */
function normalizeMetric(data) {
  return {
    loaichiso_id: data.loaichiso_id ?? data.LoaiChiSo_ID,
    tenchiso: data.tenchiso ?? data.TenChiSo,
    donvido: data.donvido ?? data.DonViDo,
    category: data.category ?? data.Category,
  };
}

function normalizeHealthData(data) {
  return {
    giatri: data.giatri ?? data.GiaTri,
    thietbi_id: data.thietbi_id ?? data.ThietBi_ID,
    loaichiso_id: data.loaichiso_id ?? data.LoaiChiSo_ID,
    thoigiancapnhat:
      data.thoigiancapnhat ??
      data.ThoiGianCapNhat ??
      new Date().toISOString(),
  };
}

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
   TẠO CHỈ SỐ
========================= */
export async function createHealthMetric(data) {
  const db = getDB();
  const d = normalizeMetric(data);

  if (!d.loaichiso_id || !d.tenchiso || !d.donvido) {
    throw new Error("Thiếu dữ liệu chỉ số");
  }

  const { error } = await db.from("loaichisosuckhoe").insert({
    loaichiso_id: d.loaichiso_id,
    tenchiso: d.tenchiso,
    donvido: d.donvido,
    mota: "",
    loai: d.category,
  });

  if (error) throw error;
}

/* =========================
   ENSURE DEVICE
========================= */
export async function ensureDeviceForUser(nguoiDungId) {
  const db = getDB();

  const { data, error } = await db
    .from("thietbisuckhoe")
    .select("thietbi_id")
    .eq("nguoidung_id", nguoiDungId)
    .eq("daxoa", 0)
    .limit(1);

  if (error) throw error;

  if (data.length > 0) {
    return data[0].thietbi_id;
  }

  const thietBiId = ("HC" + String(nguoiDungId || "")
    .replace(/\s/g, "")
    .slice(-10))
    .padEnd(12, "0")
    .slice(0, 12);

  const { error: insertError } = await db
    .from("thietbisuckhoe")
    .insert({
      thietbi_id: thietBiId,
      nguoidung_id: nguoiDungId,
      daxoa: 0,
    });

  if (insertError) throw insertError;

  return thietBiId;
}

/* =========================
   LƯU DỮ LIỆU
========================= */
export async function saveHealthData(data) {
  const db = getDB();
  const d = normalizeHealthData(data);

  // ⚠️ fix 0 vẫn hợp lệ
  if (d.giatri === undefined || d.giatri === null || d.giatri === "") {
    throw new Error("Thiếu GiaTri");
  }

  if (!d.thietbi_id || !d.loaichiso_id) {
    throw new Error("Thiếu ThietBi_ID hoặc LoaiChiSo_ID");
  }

  const id = (
    Date.now().toString() +
    Math.floor(Math.random() * 1000).toString().padStart(3, "0")
  ).slice(-12);

  const { error } = await db.from("dulieusuckhoe").insert({
    dulieusk_id: id,
    giatri: d.giatri,
    thoigiancapnhat: d.thoigiancapnhat,
    thietbi_id: d.thietbi_id,
    loaichiso_id: d.loaichiso_id,
  });

  if (error) throw error;
}

/* =========================
   LẤY DATA MỚI NHẤT
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
   HISTORY
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
   REPORT
========================= */
export async function getHealthReport(thietBiId, type) {
  const db = getDB();

  let fromDate = new Date();

  if (type === "week") {
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