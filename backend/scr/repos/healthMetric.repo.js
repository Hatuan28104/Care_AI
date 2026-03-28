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
    .eq("daxoa", false) 
    .limit(1);

  if (error) throw error;

  if (data && data.length > 0) {
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
      daxoa: false, 
    });

  if (insertError) {
    console.error("Insert device error:", insertError); 
    throw insertError;
  }

  return thietBiId;
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
/* =========================
   MAP CHỈ SỐ (RAW → DB)
========================= */
function mapLoaiChiSo(raw) {
  const map = {
    HR: "CS001",       // Nhịp tim
    STEPS: "CS004",    // Bước chân
    DISTANCE: "CS023", // Quãng đường
    SPO2: "CS018",     // SpO2
    SLEEP: "CS037",    // Ngủ
    HRV: "CS008",      // HRV
  };

  return map[raw] || null;
}

/* =========================
   LƯU NHIỀU CHỈ SỐ (OPTIONAL)
========================= */

export async function saveMultipleHealthData(payload) {
  const db = getDB();

  // =========================
  // 🔥 VALIDATE USER (QUAN TRỌNG NHẤT)
  // =========================
  if (!payload.nguoidung_id) {
    throw new Error("Thiếu nguoidung_id");
  }

  // =========================
  // 🔥 DEVICE
  // =========================
  let thietbi_id = payload.thietbi_id ?? payload.ThietBi_ID;

  if (!thietbi_id) {
    thietbi_id = await ensureDeviceForUser(payload.nguoidung_id);
  }

  if (!thietbi_id) {
    throw new Error("Thiếu ThietBi_ID");
  }

  // =========================
  // 🔥 TIME
  // =========================
  const now = new Date(Date.now() + 7 * 60 * 60 * 1000).toISOString();

 
  // =========================
  // 🔥 NORMALIZE INPUT (FIX SINGLE + MULTI)
  // =========================
  const normalizedPayload = {
    hr: payload.hr ?? payload.HR,
    steps: payload.steps ?? payload.STEPS,
    distance: payload.distance ?? payload.DISTANCE,
    spo2: payload.spo2 ?? payload.SPO2,
    sleep: payload.sleep ?? payload.SLEEP,
    hrv: payload.hrv ?? payload.HRV,
  };

  const fields = [
    { key: "hr", raw: "HR" },
    { key: "steps", raw: "STEPS" },
    { key: "distance", raw: "DISTANCE" },
    { key: "spo2", raw: "SPO2" },
    { key: "sleep", raw: "SLEEP" },
    { key: "hrv", raw: "HRV" },
  ];

  const inserts = [];

  // =========================
  // 🔥 LOOP SAVE
  // =========================
  for (let f of fields) {
    const value = normalizedPayload[f.key];

    if (value === undefined || value === null || value === "") continue;

    const loaichiso_id = mapLoaiChiSo(f.raw);
    if (!loaichiso_id) continue;

    // 🔥 CHECK EXISTING TRONG NGÀY
    const { data: existing } = await db
      .from("dulieusuckhoe")
      .select("dulieusk_id, giatri")
      .eq("thietbi_id", thietbi_id)
      .eq("loaichiso_id", loaichiso_id)
      .order("thoigiancapnhat", { ascending: false }) 
      .limit(1);
      if (existing && existing.length > 0) {
        const last = existing[0];

        if (Number(last.giatri) === Number(value)) {
          // 🔥 giống → update time
          await db
            .from("dulieusuckhoe")
            .update({
              thoigiancapnhat: now
            })
            .eq("dulieusk_id", last.dulieusk_id);

          continue;
        }
      }

    // 🔥 INSERT mới
    const id =
      Date.now().toString() +
      Math.random().toString(36).substring(2, 6);

    inserts.push({
      dulieusk_id: id,
      giatri: value,
      thoigiancapnhat: now,
      thietbi_id,
      loaichiso_id,
      nguoidung_id: payload.nguoidung_id 
    });
  }

  // =========================
  // 🔥 INSERT BATCH
  // =========================
  if (inserts.length > 0) {
    const { error } = await db.from("dulieusuckhoe").insert(inserts);

    if (error) {
      console.error("Insert multiple error:", error);
      throw error;
    }
  }

  return true;
}