import { getDB } from "../config/db.js";
import {
  getVNStartOfDayUTC,
  getVNEndOfDayUTC,
  getVNDateString,
  getCurrentVNHour,
} from "../utils/time.js";

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
  let time = data.thoigiancapnhat ?? data.ThoiGianCapNhat;

  if (!time) {
    time = new Date().toISOString();
  } else if (
    typeof time === "string" &&
    !time.includes("Z") &&
    !time.includes("+")
  ) {
    // Nếu chuỗi không có múi giờ → coi là giờ VN và convert về UTC
    const d = new Date(time);
    if (!isNaN(d.getTime())) {
      d.setUTCHours(d.getUTCHours() - 7);
      time = d.toISOString();
    }
  }

  return {
    giatri: data.giatri ?? data.GiaTri,
    nguondulieu_id: data.nguondulieu_id ?? data.NguonDuLieu_ID,
    loaichiso_id: data.loaichiso_id ?? data.LoaiChiSo_ID,
    thoigiancapnhat: time,
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
    .from("nguondulieusuckhoe")
    .select("nguondulieu_id")
    .eq("nguoidung_id", nguoiDungId)
    .eq("dangatketnoi", false)
    .limit(1);

  if (error) throw error;

  if (data && data.length > 0) {
    return data[0].nguondulieu_id;
  }

  const nguonDuLieuId = (
    "HC" +
    String(nguoiDungId || "")
      .replace(/\s/g, "")
      .slice(-10)
  )
    .padEnd(12, "0")
    .slice(0, 12);

  const { error: insertError } = await db.from("nguondulieusuckhoe").insert({
    nguondulieu_id: nguonDuLieuId,
    nguoidung_id: nguoiDungId,
    dangatketnoi: false,
  });

  if (insertError) {
    console.error("Insert device error:", insertError);
    throw insertError;
  }

  return nguonDuLieuId;
}

/* =========================
   LẤY DATA MỚI NHẤT
========================= */
export async function getLatestHealthDataByDevice(thietBiId) {
  const db = getDB();

  const { data, error } = await db
    .from("dulieusuckhoe")
    .select(
      `
      giatri,
      thoigiancapnhat,
      loaichisosuckhoe (
        loaichiso_id,
        tenchiso,
        donvido
      )
    `,
    )
    .eq("nguondulieu_id", thietBiId)
    .order("thoigiancapnhat", { ascending: false });

  if (error) throw error;

  const map = {};

  for (let item of data) {
    const key = item.loaichisosuckhoe.loaichiso_id;
    if (!map[key]) map[key] = item;
  }

  return Object.values(map).map((item) => ({
    ...item,
    thoigiancapnhat: item.thoigiancapnhat
      ? new Date(item.thoigiancapnhat).toISOString()
      : "",
  }));
}
export async function getLatestHealthDataByUser(nguoiDungId) {
  const db = getDB();
  console.log(
    "[latest-user] repo getLatestHealthDataByUser userId:",
    nguoiDungId,
  );

  const { data, error } = await db
    .from("dulieusuckhoe")
    .select(
      `
      giatri,
      thoigiancapnhat,
      nguondulieu_id,
      loaichisosuckhoe (
        loaichiso_id,
        tenchiso,
        donvido
      )
    `,
    )
    .eq("nguoidung_id", nguoiDungId)
    .order("thoigiancapnhat", { ascending: false });

  if (error) {
    console.error("[latest-user] Supabase error:", error);
    console.error("[latest-user] Supabase message:", error.message);
    throw error;
  }

  console.log("[latest-user] Supabase data length:", data?.length ?? 0);

  const map = {};

  for (let item of data) {
    if (!item.loaichisosuckhoe) {
      console.log("[latest-user] missing loaichisosuckhoe relation:", item);
    }
    const key = item.loaichisosuckhoe.loaichiso_id;

    if (!map[key]) {
      map[key] = item;
    }
  }

  return Object.values(map).map((item) => ({
    ...item,
    thoigiancapnhat: item.thoigiancapnhat
      ? new Date(item.thoigiancapnhat).toISOString()
      : "",
  }));
}
/* =========================
   HISTORY
========================= */
export async function getHealthHistory(thietBiId, loaiChiSoId) {
  const db = getDB();

  const { data, error } = await db
    .from("dulieusuckhoe")
    .select("giatri, thoigiancapnhat")
    .eq("nguondulieu_id", thietBiId)
    .eq("loaichiso_id", loaiChiSoId)
    .order("thoigiancapnhat", { ascending: false })
    .limit(50);

  if (error) throw error;

  return (data || []).map((item) => ({
    ...item,
    thoigiancapnhat: item.thoigiancapnhat
      ? new Date(item.thoigiancapnhat).toISOString()
      : "",
  }));
}
export async function getHealthHistoryByUser(
  nguoiDungId,
  loaiChiSoId,
  range = "d",
) {
  const db = getDB();

  const { data, error } = await db
    .from("dulieusuckhoe")
    .select("giatri, thoigiancapnhat")
    .eq("nguoidung_id", nguoiDungId)
    .eq("loaichiso_id", loaiChiSoId)
    .order("thoigiancapnhat", { ascending: true })
    .limit(200);

  if (error) throw error;
  if (!data) return [];

  let fromDate;
  const now = new Date();

  if (range === "d") {
    fromDate = new Date(now.getTime() - 24 * 60 * 60 * 1000);
  } else if (range === "w") {
    fromDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
  } else if (range === "m") {
    fromDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
  } else if (range === "m6") {
    fromDate = new Date(now.getTime());
    fromDate.setUTCMonth(now.getUTCMonth() - 6);
  } else {
    fromDate = new Date(0); // All time
  }

  const filtered = data.filter((d) => {
    const t = new Date(d.thoigiancapnhat);
    return t >= fromDate;
  });

  console.log("HISTORY LENGTH:", filtered.length);

  return filtered.map((item) => ({
    ...item,
    thoigiancapnhat: item.thoigiancapnhat
      ? new Date(item.thoigiancapnhat).toISOString()
      : "",
  }));
}
/* =========================
   REPORT
========================= */
export async function getHealthReport(userId, quanHeId, type) {
  const db = getDB();

  // 1. check quyền quan hệ
  const { data: rel } = await db
    .from("quanhegiamho")
    .select("nguoiduocgiamho_id")
    .eq("quanhegiamho_id", quanHeId)
    .or(`nguoigiamho_id.eq.${userId},nguoiduocgiamho_id.eq.${userId}`)
    .eq("daxoa", false)
    .single();


  if (!rel) throw new Error("Không có quyền");

  const dependentId = rel.nguoiduocgiamho_id;

  // 2. lấy quyền
  const { data: configs } = await db
    .from("cauhinhdulieu")
    .select("quyen")
    .eq("quanhegiamho_id", quanHeId)
    .eq("dakichhoat", true);

  const allowed = (configs || [])
    .map((i) => i.quyen)
    .filter((q) => q.startsWith("CS"));
  let finalAllowed = allowed;

  if (finalAllowed.length === 0) {
    const { data: metrics } = await db
      .from("loaichisosuckhoe")
      .select("loaichiso_id");

    finalAllowed = (metrics || []).map((m) => m.loaichiso_id);
  }
  // 3. time range
  let fromDate = new Date();
  if (["day", "d"].includes(type)) {
    fromDate.setUTCDate(fromDate.getUTCDate() - 1);
  }

  if (["week", "w"].includes(type)) {
    fromDate.setUTCDate(fromDate.getUTCDate() - 7);
  }

  if (["month", "m"].includes(type)) {
    fromDate.setUTCDate(fromDate.getUTCDate() - 30);
  }

  // 4. query data
  const { data, error } = await db
    .from("dulieusuckhoe")
    .select(
      `
      giatri,
      loaichiso_id,
      thoigiancapnhat,
      loaichisosuckhoe (
        tenchiso,
        donvido
      )
    `,
    )
    .eq("nguoidung_id", dependentId)
    .in("loaichiso_id", finalAllowed) // 🔥 SHARE CORE
    .gte("thoigiancapnhat", fromDate.toISOString());

  if (error) throw error;

  // 5. group theo chỉ số (avg hoặc latest)
  const map = {};

  for (let item of data || []) {
    const key = item.loaichiso_id;

    if (!map[key]) {
      map[key] = {
        loaichiso_id: key,
        tenchiso: item.loaichisosuckhoe?.tenchiso,
        donvido: item.loaichisosuckhoe?.donvido,
        total: 0,
        count: 0,
        latest: item.giatri,
      };
    }

    map[key].total += item.giatri;
    map[key].count++;
  }

  // 6. return dynamic
  return Object.values(map).map((i) => ({
    loaichiso_id: i.loaichiso_id,
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

  let nguondulieu_id =
    payload.nguondulieu_id ??
    payload.NguonDuLieu_ID ??
    payload.thietbi_id ??
    payload.ThietBi_ID;

  const isManual = !nguondulieu_id;

  // =========================
  // TIME UTC BOUNDARIES (VN DAY)
  // =========================
  const nowISO = new Date().toISOString();
  const startOfDayVN = getVNStartOfDayUTC();
  const endOfDayVN = getVNEndOfDayUTC();

  const inserts = [];

  // =========================
  // LOOP ALL PAYLOAD
  // =========================
  for (const [key, value] of Object.entries(payload)) {
    if (
      [
        "type",
        "nguondulieu_id",
        "NguonDuLieu_ID",
        "thietbi_id",
        "ThietBi_ID",
        "nguoidung_id",
      ].includes(key)
    )
      continue;

    if (
      value === undefined ||
      value === null ||
      value === "" ||
      Number(value) <= 0
    )
      continue;

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
      .gte("thoigiancapnhat", startOfDayVN)
      .lte("thoigiancapnhat", endOfDayVN)
      .order("thoigiancapnhat", { ascending: false })
      .limit(1);

    if (existing && existing.length > 0) {
      const oldValue = Number(existing[0].giatri);

      if (oldValue === Number(value)) {
        await db
          .from("dulieusuckhoe")
          .update({
            thoigiancapnhat: nowISO,
            nguondulieu_id: isManual ? null : nguondulieu_id,
          })
          .eq("dulieusk_id", existing[0].dulieusk_id);

        console.log(`UPDATE TIME (same value) ${loaichiso_id}`);
      } else {
        // ✅ khác giá trị → insert mới
        const id =
          Date.now().toString() + Math.random().toString(36).substring(2, 6);

        inserts.push({
          dulieusk_id: id,
          giatri: value,
          thoigiancapnhat: nowISO,
          nguondulieu_id: isManual ? null : nguondulieu_id,
          loaichiso_id,
          nguoidung_id: payload.nguoidung_id,
        });

        console.log(`INSERT NEW VALUE ${loaichiso_id}`);
      }
    } else {
      // ✅ chưa có trong ngày → insert
      const id =
        Date.now().toString() + Math.random().toString(36).substring(2, 6);

      inserts.push({
        dulieusk_id: id,
        giatri: value,
        thoigiancapnhat: nowISO,
        nguondulieu_id: isManual ? null : nguondulieu_id,
        loaichiso_id,
        nguoidung_id: payload.nguoidung_id,
      });

      console.log(`INSERT FIRST ${loaichiso_id}`);
    }
  }

  // =========================
  // INSERT BATCH
  // =========================
  // =========================
  // INSERT BATCH
  // =========================
  if (inserts.length > 0) {
    const { data, error } = await db.from("dulieusuckhoe").insert(inserts)
      .select(`
      dulieusk_id,
      nguoidung_id,
      loaichiso_id,
      giatri,
      loaichisosuckhoe (
        code
      )
    `);

    if (error) throw error;

    return data || [];
  }

  return [];
}
/* =========================
   PHÂN TÍCH AI
========================= */
export async function insertAIInsight(nguoidung_id, insightData) {
  const db = getDB();

  if (!nguoidung_id || !insightData) return;

  console.log("[Phân tích AI] Inserting for user:", nguoidung_id);

  const { error } = await db.from("phantich_ai").insert({
    nguoidung_id,
    trangthai: insightData.trangthai ?? "unknown",
    thongdiep: insightData.thongdiep ?? "",
    loikhuyen: insightData.loikhuyen ?? "",
    sosanh: insightData.sosanh ?? {},
    thoigian: insightData.thoigian ?? new Date().toISOString(),
  });

  if (error) {
    console.error("[Phân tích AI] DB INSERT ERROR:", error);
    throw error;
  }

  console.log("[Phân tích AI] Insert OK for user:", nguoidung_id);
}

export async function getAIInsightByDate(nguoidung_id, dateStr) {
  const db = getDB();

  const startOfDay = getVNStartOfDayUTC(new Date(dateStr));
  const endOfDay = getVNEndOfDayUTC(new Date(dateStr));

  const { data, error } = await db
    .from("phantich_ai")
    .select("trangthai, thongdiep, loikhuyen, sosanh, thoigian")
    .eq("nguoidung_id", nguoidung_id)
    .gte("thoigian", startOfDay)
    .lte("thoigian", endOfDay)
    .order("thoigian", { ascending: false })
    .limit(1);

  if (error) {
    console.error("[Phân tích AI] GET BY DATE ERROR:", error.message);
    return null;
  }
  return data && data.length > 0 ? data[0] : null;
}

export async function getLatestAIInsight(nguoidung_id) {
  const db = getDB();
  const { data, error } = await db
    .from("phantich_ai")
    .select("trangthai, thongdiep, loikhuyen, sosanh, thoigian")
    .eq("nguoidung_id", nguoidung_id)
    .order("thoigian", { ascending: false })
    .limit(1);

  if (error) {
    console.error("Lỗi lấy phân tích AI:", error.message);
    return null;
  }
  return data && data.length > 0 ? data[0] : null;
}

export async function getStressInputData(nguoiDungId, deviceId) {
  const db = getDB();
  const targetMetricIds = ["CS008", "CS001", "CS037", "CS004"];

  // Lấy dữ liệu 14 ngày để AI có đủ "chuỗi lịch sử" (history series)
  const fourteenDaysAgo = new Date(
    Date.now() - 14 * 24 * 60 * 60 * 1000,
  ).toISOString();

  const { data, error } = await db
    .from("dulieusuckhoe")
    .select("loaichiso_id, giatri, thoigiancapnhat")
    .eq("nguoidung_id", nguoiDungId)
    .in("loaichiso_id", targetMetricIds)
    .gte("thoigiancapnhat", fourteenDaysAgo)
    .order("thoigiancapnhat", { ascending: false })
    .limit(1000);

  if (error) {
    console.error("[latest-user] Supabase stress input error:", error);
    console.error(
      "[latest-user] Supabase stress input message:",
      error.message,
    );
    throw error;
  }

  const rows = data || [];
  const valuesByMetric = {
    CS008: [],
    CS001: [],
    CS037: [],
    CS004: [],
  };

  for (const row of rows) {
    if (!valuesByMetric[row.loaichiso_id]) continue;
    const val = Number(row.giatri);
    if (!Number.isFinite(val)) continue;
    valuesByMetric[row.loaichiso_id].push(val);
  }

  const hrvSeries = valuesByMetric.CS008;
  const hrSeries = valuesByMetric.CS001;
  const sleepSeries = valuesByMetric.CS037;
  const stepsSeries = valuesByMetric.CS004;
  const currentHour = getCurrentVNHour();

  const vnMidnight = new Date(getVNStartOfDayUTC());

  // --- 1. KIỂM TRA TRẠNG THÁI ĐEO TRONG NGÀY (TODAY CHECK) ---
  // Nếu từ 00:00 đến nay hoàn toàn không có nhịp tim -> Coi như chưa đeo thiết bị hôm nay
  const hrToday = rows.filter(
    (r) =>
      r.loaichiso_id === "CS001" && new Date(r.thoigiancapnhat) >= vnMidnight,
  );

  if (hrToday.length === 0) {
    console.log(
      "[STRESS-INPUT] Ngày mới chưa có dữ liệu nhịp tim -> Giữ nguyên giá trị stress cũ.",
    );
    throw new Error("NOT_ENOUGH_DATA");
  }

  // --- 2. TÍNH TOÁN HRV ĐẦU VÀO ---
  const nightStart = new Date(vnMidnight.getTime() - 2 * 3600000); // 22:00 hôm trước
  const nightEnd = new Date(vnMidnight.getTime() + 10 * 3600000); // 10:00 hôm nay

  // Logic Calibration: Đếm số ngày duy nhất có dữ liệu trong 7 ngày gần nhất
  const sevenDaysLimit = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
  const uniqueDays = new Set();

  for (const row of rows) {
    const rowDate = new Date(row.thoigiancapnhat);
    if (rowDate >= sevenDaysLimit) {
      const vnDateStr = getVNDateString(rowDate);
      uniqueDays.add(vnDateStr);
    }
  }

  const calibrationDays = Math.min(uniqueDays.size, 3);

  let sleepValue = 0;
  let sleepWarning = null;
  let hasSleepData = false;

  // ============================================================
  // PHÁT HIỆN GIẤC NGỦ (Phân tách Case A vs Case B/C)
  // ============================================================

  // --- Ưu tiên 1: Luôn tìm chỉ số giấc ngủ CS037 trực tiếp từ thiết bị ---
  const todayDateStr = getVNDateString();
  const todaySleep = rows.find(
    (r) =>
      r.loaichiso_id === "CS037" &&
      getVNDateString(new Date(r.thoigiancapnhat)) === todayDateStr,
  );

  if (todaySleep) {
    sleepValue = Number(todaySleep.giatri);
    hasSleepData = true;
    console.log(`[SLEEP] Đã tìm thấy dữ liệu CS037: ${sleepValue}h`);
  }

  // --- Ưu tiên 2: Xử lý khi thiếu CS037 ---
  if (!hasSleepData) {
    if (currentHour < 10) {
      // TRƯỜNG HỢP B & C: BAN ĐÊM (Dưới 10h sáng)
      // Dùng HR Pattern để xác nhận thức trắng hoặc tìm đoạn ngủ ngắn
      console.log(
        `[SLEEP-B/C] Đang trong khung giờ đêm/sáng sớm (<10h) -> Chạy HR Pattern`,
      );

      const vnMidnightUTC = new Date(getVNStartOfDayUTC());
      const vnYesterday22hUTC = new Date(vnMidnightUTC.getTime() - 2 * 3600000);
      const vn6hUTC = new Date(vnMidnightUTC.getTime() + 6 * 3600000);
      const vn10hUTC = new Date(vnMidnightUTC.getTime() + 10 * 3600000);

      const hrRecords = rows
        .filter((r) => r.loaichiso_id === "CS001" && r.thoigiancapnhat)
        .map((r) => ({
          value: Number(r.giatri),
          time: new Date(r.thoigiancapnhat),
        }))
        .filter((r) => Number.isFinite(r.value));

      // B1: Core check 0h-6h
      const hrIn0to6 = hrRecords.filter(
        (r) => r.time >= vnMidnightUTC && r.time < vn6hUTC,
      );
      if (hrIn0to6.length === 0) {
        console.log(
          `[SLEEP-B1] Không có HR trong 0h–6h → Không đủ dữ liệu ban đêm`,
        );
        throw new Error("NOT_ENOUGH_DATA");
      }

      // B2: Coverage check 6h-10h
      if (currentHour >= 6) {
        const hrIn6to10 = hrRecords.filter(
          (r) => r.time >= vn6hUTC && r.time < vn10hUTC,
        );
        if (hrIn6to10.length === 0) throw new Error("NOT_ENOUGH_DATA");
      }

      // B3: Xác nhận thức trắng hay có ngủ qua HR
      const hrInNightWindow = hrRecords
        .filter((r) => r.time >= vnYesterday22hUTC && r.time < vn10hUTC)
        .sort((a, b) => a.time - b.time);

      const vn10hYesterdayUTC = new Date(
        vnMidnightUTC.getTime() - 14 * 3600000,
      );
      const daytimeHr = hrRecords.filter(
        (r) => r.time >= vn10hYesterdayUTC && r.time < vnYesterday22hUTC,
      );

      let baseline = null;
      if (daytimeHr.length >= 5) {
        // Yêu cầu ít nhất 5 bản ghi ban ngày để có baseline tin cậy
        baseline =
          daytimeHr.reduce((sum, r) => sum + r.value, 0) / daytimeHr.length;
      } else {
        const allDaytimeHr = hrRecords.filter((r) => {
          const vnH = (r.time.getUTCHours() + 7) % 24;
          return vnH >= 10 && vnH < 22;
        });
        if (allDaytimeHr.length >= 5)
          baseline =
            allDaytimeHr.reduce((sum, r) => sum + r.value, 0) /
            allDaytimeHr.length;
      }

      if (baseline && hrInNightWindow.length >= 2) {
        const threshold = baseline * 0.875;
        let sleepStart = null;
        let maxSleepMs = 0;

        for (const record of hrInNightWindow) {
          if (record.value <= threshold) {
            if (!sleepStart) sleepStart = record.time;
            const durationMs = record.time - sleepStart;
            if (durationMs > maxSleepMs) maxSleepMs = durationMs;
          } else {
            sleepStart = null;
          }
        }

        const maxSleepHours = maxSleepMs / 3600000;

        if (maxSleepHours >= 1) {
          // HR giảm -> Có ngủ nhưng vì thiếu CS037 nên không rõ thời lượng
          sleepValue = null;
          hasSleepData = false;
          console.log(
            `[SLEEP-B3] HR có giảm (${maxSleepHours.toFixed(1)}h) -> Có ngủ nhưng thiếu CS037 -> gán null (model no-sleep)`,
          );
        } else {
          // HR không giảm -> Xác nhận thức trắng đêm
          sleepValue = 0;
          hasSleepData = true;
          console.log(
            `[SLEEP-B3] HR không giảm -> Xác nhận thức trắng -> gán 0 (model bình thường)`,
          );
        }
      } else {
        // Có đeo máy nhưng không đủ dữ liệu baseline để so sánh nhịp tim
        console.log(
          `[SLEEP-B3] Có dữ liệu HR nhưng không xác nhận được thức trắng (thiếu baseline) -> null`,
        );
        sleepValue = null;
      }
    } else {
      // TRƯỜNG HỢP A: BAN NGÀY (Sau 10h sáng)
      // Không có CS037 thì để null luôn, không cố suy luận từ HR nữa
      console.log(
        `[SLEEP-A] Ban ngày (>10h) và không có CS037 -> Để null giấc ngủ`,
      );
      sleepValue = null;
    }
  }

  // --- TRƯỜNG HỢP 2: THIẾU GIẤC NGỦ -> CHẠY MODEL NO-SLEEP (GỬI NULL) ---
  // (Logic này đã được xử lý phía trên, nếu không tìm thấy CS037, sleepValue sẽ là null)
  // Không có giấc ngủ từ bất kỳ nguồn nào → gửi null để AI dùng model no-sleep
  if (!hasSleepData) {
    sleepValue = null;
    sleepWarning =
      "Bạn vừa đo stress, nhưng hệ thống không có dữ liệu giấc ngủ gần nhất vì đồng hồ không được đeo khi ngủ.\n\nKết quả vẫn được tính toán, nhưng độ chính xác có thể thấp hơn. Hãy đeo đồng hồ khi ngủ để nhận phân tích đầy đủ hơn.";
    console.log(
      `[SLEEP] KHÔNG CÓ dữ liệu giấc ngủ → sleep=null, dùng model no-sleep`,
    );
  }

  // ============================================================
  // TÍNH TOÁN HRV ĐẦU VÀO (DỰA TRÊN KẾT QUẢ GIẤC NGỦ)
  // ============================================================
  const latestHrvRow = rows.find((r) => r.loaichiso_id === "CS008");
  if (!latestHrvRow) throw new Error("NOT_ENOUGH_DATA");

  const latestHrvTime = new Date(latestHrvRow.thoigiancapnhat).getTime();
  // Mốc thời gian kết thúc giấc ngủ (nếu có CS037)
  const sleepEndTime = todaySleep
    ? new Date(todaySleep.thoigiancapnhat).getTime()
    : 0;

  let hrvVal = 0;

  // Phân biệt HRV sinh ra trong lúc ngủ vs HRV sau khi ngủ dậy
  if (hasSleepData && sleepValue > 0 && latestHrvTime <= sleepEndTime) {
    // TRƯỜNG HỢP: Lần đầu đo sau dậy, dữ liệu HRV hiện tại vẫn là dữ liệu từ lúc ngủ
    // Lấy danh sách HRV từ 22h hôm trước đến thời điểm kết thúc giấc ngủ
    const hrvDuringSleep = rows.filter((r) => {
      if (r.loaichiso_id !== "CS008") return false;
      const t = new Date(r.thoigiancapnhat).getTime();
      return t >= nightStart.getTime() && t <= sleepEndTime;
    });

    if (hrvDuringSleep.length > 0) {
      const sum = hrvDuringSleep.reduce((s, r) => s + Number(r.giatri), 0);
      hrvVal = sum / hrvDuringSleep.length;
      console.log(
        `[STRESS-INPUT] Lần đầu sau dậy -> Dùng TB HRV trong lúc ngủ: ${hrvVal.toFixed(1)}ms (${hrvDuringSleep.length} mẫu)`,
      );
    } else {
      hrvVal = Number(latestHrvRow.giatri);
    }
  } else {
    // TRƯỜNG HỢP: Đã có HRV mới sau khi dậy, hoặc thức trắng/không có dữ liệu ngủ
    hrvVal = Number(latestHrvRow.giatri);
    console.log(
      `[STRESS-INPUT] Đo sau khi dậy hoặc không ngủ -> Dùng HRV gần nhất: ${hrvVal}ms`,
    );
  }

  // Kiểm tra bước chân hôm nay
  let todaySteps = 0;
  const latestStep = rows.find((r) => r.loaichiso_id === "CS004");
  if (latestStep) {
    const stepDate = getVNDateString(new Date(latestStep.thoigiancapnhat));
    if (stepDate === getVNDateString()) todaySteps = Number(latestStep.giatri);
  }

  return {
    hrv_rmssd_ms: hrvVal,
    resting_hr_bpm: hrSeries[0],
    sleep_duration_hours: sleepValue,
    steps: todaySteps,
    hrv_history: hrvSeries.slice(1, 8).reverse(),
    sleep_history: sleepSeries.slice(1, 8).reverse(),
    hr_history: hrSeries.slice(1, 8).reverse(),
    calibration_days: calibrationDays,
    sleep_warning: sleepWarning,
    debug_row_count: rows.length,
    debug_first_row: rows[0] || null,
  };
}

export async function saveHealthData(payload) {
  const db = getDB();

  const normalized = normalizeHealthData(payload);
  const nguoidung_id = payload.nguoidung_id ?? payload.NguoiDung_ID;

  if (!normalized.loaichiso_id) throw new Error("Thiếu loaichiso_id");
  if (
    normalized.giatri === undefined ||
    normalized.giatri === null ||
    normalized.giatri === ""
  ) {
    throw new Error("Thiếu giatri");
  }

  const record = {
    dulieusk_id:
      Date.now().toString() + Math.random().toString(36).substring(2, 6),
    giatri: Number(normalized.giatri),
    thoigiancapnhat: new Date(normalized.thoigiancapnhat).toISOString(),
    nguondulieu_id: normalized.nguondulieu_id ?? null,
    loaichiso_id: normalized.loaichiso_id,
    nguoidung_id: nguoidung_id ?? null,
  };

  const { data, error } = await db
    .from("dulieusuckhoe")
    .insert(record)
    .select(
      `
      dulieusk_id,
      nguoidung_id,
      loaichiso_id,
      giatri,
      loaichisosuckhoe (
        code
      )
    `,
    )
    .single();

  if (error) throw error;

  return data;
}

export async function getLatestMetricByDevice(thietBiId, loaiChiSoId) {
  const db = getDB();

  const { data, error } = await db
    .from("dulieusuckhoe")
    .select("giatri, thoigiancapnhat")
    .eq("nguondulieu_id", thietBiId)
    .eq("loaichiso_id", loaiChiSoId)
    .order("thoigiancapnhat", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (error) throw error;
  return data || null;
}
