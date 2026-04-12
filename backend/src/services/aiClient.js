import axios from 'axios';
import { getDB } from '../config/db.js';

const AI_SERVER_URL = process.env.AI_SERVER_URL || 'https://aiservice-production-d85e.up.railway.app';

const metricsMap = {
  "CS004": "steps",
  "CS037": "sleep_hours",
  "CS001": "heart_rate",
  "CS018": "spo2",
  "CS008": "hrv",
  "CS023": "distance"
};


export const fetchAIHistory = async (nguoidungId) => {
  const db = getDB();
  const { data, error } = await db
    .from("dulieusuckhoe")
    .select("thoigiancapnhat,loaichiso_id,giatri")
    .eq("nguoidung_id", nguoidungId)
    .order("thoigiancapnhat", { ascending: false })
    .limit(50);

  if (error || !data) return [];

  const pivot = {};
  for (let r of data) {
    const time = r.thoigiancapnhat;
    const dateStr = time
      ? time.split('T')[0]
      : new Date().toISOString().split('T')[0];

    if (!pivot[dateStr]) {
      pivot[dateStr] = { date: dateStr };
    }

    const cid = r.loaichiso_id;
    const val = r.giatri;

    if (metricsMap[cid]) {
      pivot[dateStr][metricsMap[cid]] = val;
    }
  }

  const today = new Date().toISOString().split('T')[0];

  return Object.values(pivot)
    .filter(d => d.date !== today)
    .sort((a, b) => a.date.localeCompare(b.date))
    .slice(-7);
};
export const callSelfEvolutionAI = async (nguoidung_id, currentBody) => {
  try {
    const history = await fetchAIHistory(nguoidung_id);

    const current_metrics = {
      date: new Date().toISOString().split('T')[0]
    };

    for (const [key, value] of Object.entries(currentBody)) {
      if (metricsMap[key]) current_metrics[metricsMap[key]] = Number(value) || 0;
      if (Object.values(metricsMap).includes(key)) current_metrics[key] = Number(value) || 0;
    }

    const payload = {
      nguoidung_id,
      current_metrics,
      history
    };

    const url = `${AI_SERVER_URL}/self/self_evolution`;
    console.log("[AI Client] Calling:", url);

    const response = await axios.post(url, payload, {
      timeout: 10000
    });

    const raw = response.data || {};
    const sosanhRaw = raw.sosanh ?? {};
    const normalized = {
      trangthai: (raw.trangthai ?? raw.status ?? "unknown").toString(),
      thongdiep: (raw.thongdiep ?? raw.message ?? "").toString(),
      loikhuyen: (raw.loikhuyen ?? raw.advice ?? "").toString(),
      sosanh:
        typeof (raw.sosanh ?? raw.compare) === "object" &&
        (raw.sosanh ?? raw.compare) !== null
          ? (raw.sosanh ?? raw.compare)
          : {},
      thoigian: new Date().toISOString(),
    };

    console.log("[AI Client] Response trangthai:", normalized.trangthai);
    return normalized;
  } catch (err) {
    console.error("[AI Client] FAILED:", err.message, "| code:", err.code, "| HTTP:", err.response?.status);
    return null;
  }
};
