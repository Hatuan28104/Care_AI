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
    const dateStr = time ? time.split('T')[0] : new Date().toISOString().split('T')[0];

    if (!pivot[dateStr]) {
      pivot[dateStr] = { date: dateStr };
    }
    const cid = r.loaichiso_id;
    const val = r.giatri;

    if (metricsMap[cid]) {
      pivot[dateStr][metricsMap[cid]] = val;
    }
  }
  return Object.values(pivot).slice(0, 7);
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

    const url = `${AI_SERVER_URL}/ai/self-evolution`;
    console.log("[AI Client] Calling:", url);

    const response = await axios.post(url, payload, {
      timeout: 10000
    });

    console.log("[AI Client] Response status:", response.data?.status);
    return response.data;
  } catch (err) {
    console.error("[AI Client] FAILED:", err.message, "| code:", err.code, "| HTTP:", err.response?.status);
    return null;
  }
};
