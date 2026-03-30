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
    .select("loaichiso_id, tenchiso, donvido, mota, loai, code");

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
export async function getLatestHealthDataByDevice(thietBiId) {
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
    if (!map[key]) map[key] = item;
  }

  return Object.values(map);
}
export async function getLatestHealthDataByUser(nguoiDungId) {
  const db = getDB();

  const { data, error } = await db
    .from("dulieusuckhoe")
    .select(`
      giatri,
      thoigiancapnhat,
      thietbi_id,
      loaichisosuckhoe (
        loaichiso_id,
        tenchiso,
        donvido
      )
    `)
    .eq("nguoidung_id", nguoiDungId)
    .order("thoigiancapnhat", { ascending: false });

  if (error) throw error;

  const map = {};

  for (let item of data) {
    const key = item.loaichisosuckhoe.loaichiso_id;

    if (!map[key]) {
      map[key] = item;
    } else {
      const current = map[key];

      if (current.thietbi_id == null && item.thietbi_id != null) {
        map[key] = item;
      }
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
export async function getHealthHistoryByUser(
  nguoiDungId,
  loaiChiSoId,
  range = "d"
) {
  const db = getDB();

  const now = new Date();

  let fromDate = new Date();

  if (range === "d") {
    fromDate.setHours(0, 0, 0, 0); // 🔥 start today
  } else if (range === "w") {
    fromDate.setDate(now.getDate() - 7);
  } else if (range === "m") {
    fromDate.setDate(now.getDate() - 30);
  } else if (range === "m6") {
    fromDate.setMonth(now.getMonth() - 6);
  }

  // 🔥 dùng ISO chuẩn
  const fromISO = fromDate.toISOString();

  console.log("FROM:", fromISO);

  const { data, error } = await db
    .from("dulieusuckhoe")
    .select("giatri, thoigiancapnhat")
    .eq("nguoidung_id", nguoiDungId)
    .eq("loaichiso_id", loaiChiSoId)
    .gte("thoigiancapnhat", fromISO)
    .order("thoigiancapnhat", { ascending: true }); // 🔥 FIX

  if (error) {
    console.error("History error:", error);
    throw error;
  }

  console.log("HISTORY LENGTH:", data.length);

  return data || [];
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
export async function saveMultipleHealthData(payload) {
  const db = getDB();

  if (!payload.nguoidung_id) {
    throw new Error("Thiếu nguoidung_id");
  }

  const type = payload.type || "device";

  // =========================
  // LOAD METRIC MAP
  // =========================
  const { data: allMetrics } = await db
    .from("loaichisosuckhoe")
    .select("loaichiso_id, code");

  const codeMap = {};
  const metricIdSet = new Set();

  for (let m of allMetrics) {
    if (m.code) {
      codeMap[m.code.toUpperCase()] = m.loaichiso_id;
    }
    metricIdSet.add(m.loaichiso_id);
  }


  let thietbi_id = payload.thietbi_id ?? payload.ThietBi_ID;

  const isManual = !thietbi_id;


  const now = new Date();
  const nowISO = now.toISOString();
  const today = nowISO.split("T")[0];

  const inserts = [];

  // =========================
  // LOOP ALL PAYLOAD
  // =========================
  for (const [key, value] of Object.entries(payload)) {
    if (["type", "thietbi_id", "ThietBi_ID", "nguoidung_id"].includes(key)) continue;

    if (value === undefined || value === null || value === "" || Number(value) <= 0) continue;

    let loaichiso_id = null;

    // ✔️ CSxxx
    if (metricIdSet.has(key)) {
      loaichiso_id = key;
    } 
    // ✔️ code (hr, steps…)
    else {
      loaichiso_id = codeMap[key.toUpperCase()];
    }

    if (!loaichiso_id) continue;

    // =========================
    // 🔥 LẤY RECORD TRONG NGÀY
    // =========================
    const { data: existing } = await db
      .from("dulieusuckhoe")
      .select("dulieusk_id, giatri, thoigiancapnhat")
      .eq("nguoidung_id", payload.nguoidung_id)
      .eq("loaichiso_id", loaichiso_id)
      .gte("thoigiancapnhat", today + "T00:00:00")
      .lte("thoigiancapnhat", today + "T23:59:59")
      .order("thoigiancapnhat", { ascending: false })
      .limit(1);

    if (existing && existing.length > 0) {
      const oldValue = Number(existing[0].giatri);

      if (oldValue === Number(value)) {
        // ✅ cùng giá trị → update time
        await db
          .from("dulieusuckhoe")
          .update({
            thoigiancapnhat: nowISO,
            thietbi_id: isManual ? null : thietbi_id,
          })
          .eq("dulieusk_id", existing[0].dulieusk_id);

        console.log(`UPDATE TIME (same value) ${loaichiso_id}`);
      } else {
        // ✅ khác giá trị → insert mới
        const id =
          Date.now().toString() +
          Math.random().toString(36).substring(2, 6);

        inserts.push({
          dulieusk_id: id,
          giatri: value,
          thoigiancapnhat: nowISO,
          thietbi_id: isManual ? null : thietbi_id,
          loaichiso_id,
          nguoidung_id: payload.nguoidung_id,
        });

        console.log(`INSERT NEW VALUE ${loaichiso_id}`);
      }
    } else {
      // ✅ chưa có trong ngày → insert
      const id =
        Date.now().toString() +
        Math.random().toString(36).substring(2, 6);

      inserts.push({
        dulieusk_id: id,
        giatri: value,
        thoigiancapnhat: nowISO,
        thietbi_id: isManual ? null : thietbi_id,
        loaichiso_id,
        nguoidung_id: payload.nguoidung_id,
      });

      console.log(`INSERT FIRST ${loaichiso_id}`);
    }
  }

  // =========================
  // INSERT BATCH
  // =========================
  if (inserts.length > 0) {
    const { error } = await db.from("dulieusuckhoe").insert(inserts);
    if (error) throw error;
  }

  return true;
}