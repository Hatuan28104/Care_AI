import { getAllHealthMetrics, createHealthMetric, getLatestHealthDataByDevice, getLatestHealthDataByUser, getHealthHistory, getHealthHistoryByUser, getHealthReport, ensureDeviceForUser, saveMultipleHealthData, insertAIInsight, getLatestAIInsight, getAIInsightByDate } from "../repos/healthMetric.repo.js";
import { sendNotification } from "../repos/notification.repo.js";
import { callSelfEvolutionAI } from "./aiClient.js";

function getCurrentTimeInVietnam() {
  const now = new Date();
  const vnTimeStr = now.toLocaleString("en-US", { timeZone: "Asia/Ho_Chi_Minh" });
  return new Date(vnTimeStr);
}

function getVNDateString(dateObj) {
  const y = dateObj.getFullYear();
  const m = String(dateObj.getMonth() + 1).padStart(2, '0');
  const d = String(dateObj.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

export const handleGetMetrics = async () => {
  const data = await getAllHealthMetrics();
  return { success: true, data };
};

export const handleCreateMetric = async (body) => {
  const loaichiso_id = body.loaichiso_id ?? body.LoaiChiSo_ID;
  const tenchiso = body.tenchiso ?? body.TenChiSo;
  const donvido = body.donvido ?? body.DonViDo;
  const category = body.category ?? body.Category;

  if (!loaichiso_id || !tenchiso || !donvido) throw new Error("Thiếu dữ liệu");

  await createHealthMetric({ loaichiso_id, tenchiso, donvido, category });
  return { success: true, message: "Đã thêm chỉ số" };
};

export const handleDeviceEnsure = async (user) => {
  const nguoiDungId = user?.NguoiDung_ID || user?.nguoidung_id;
  if (!nguoiDungId) throw new Error("Chưa đăng nhập");

  const thietBiId = await ensureDeviceForUser(nguoiDungId);
  return { success: true, data: { ThietBi_ID: thietBiId } };
};

export const handleSaveData = async (user, body) => {
  const nguoiDungId = user?.NguoiDung_ID || user?.nguoidung_id;
  if (!nguoiDungId) throw new Error("Chưa đăng nhập");

  const thietbi_id = body.thietbi_id ?? body.ThietBi_ID ?? null;

  await saveMultipleHealthData({
    ...body,
    nguoidung_id: nguoiDungId,
    thietbi_id,
  });

  const nowVN = getCurrentTimeInVietnam();
  const hour = nowVN.getHours();
  const today = getVNDateString(nowVN);

  // 🔥 check đã có AI hôm nay chưa
  const existingInsight = await getAIInsightByDate(nguoiDungId, today);

  // =========================
  // CASE 1: trước 9h
  // =========================
  if (hour < 9) {
    return {
      success: true,
      message: "Đã lưu dữ liệu, AI sẽ cập nhật sau 9h"
    };
  }

  // =========================
  // CASE 2: sau 9h nhưng đã có rồi
  // =========================
  if (existingInsight) {
    return {
      success: true,
      message: "Đã có dữ liệu hôm nay"
    };
  }

  // =========================
  // CASE 3: sau 9h và CHƯA có → chạy AI
  // (bao gồm cả data gửi trước 9h nhưng giờ mới mở app)
  // =========================
  const aiAnalysis = await callSelfEvolutionAI(nguoiDungId, body);

  if (aiAnalysis && aiAnalysis.compare) {
    await insertAIInsight(nguoiDungId, aiAnalysis, today);
    await createDailyCompareNotification(nguoiDungId, aiAnalysis);
  }

  return {
    success: true,
    message: "Đã lưu dữ liệu sức khỏe"
  };
};

export const createDailyCompareNotification = async (userId, aiEvaluation) => {
  if (!aiEvaluation || !aiEvaluation.compare) return;

  const title = "So sánh chỉ số hàng ngày";
  const body = formatCompare(aiEvaluation.compare);

  try {
    await sendNotification(userId, title, body, 1, 'DAILY_COMPARE');
  } catch (err) {
    console.error(err.message);
  }
};

function formatCompare(compare) {
  if (!compare) return "Không có dữ liệu so sánh.";
  if (typeof compare === 'string') return compare;

  const lines = [];
  for (const value of Object.values(compare)) {
    if (value) lines.push(value);
  }

  return lines.length ? lines.join("\n") : "Dữ liệu so sánh ổn định.";
}

export const handleGetLatestDeviceData = async (deviceId) => {
  const data = await getLatestHealthDataByDevice(deviceId);
  return { success: true, data };
};

export const handleGetLatestUserData = async (user) => {
  const nguoiDungId = user?.NguoiDung_ID || user?.nguoidung_id;
  if (!nguoiDungId) throw new Error("Chưa đăng nhập");

  const data = await getLatestHealthDataByUser(nguoiDungId);
  return { success: true, data };
};

export const handleGetHistoryByUser = async (user, metricId, range) => {
  const nguoiDungId = user?.NguoiDung_ID || user?.nguoidung_id;
  if (!nguoiDungId) throw new Error("Chưa đăng nhập");

  const data = await getHealthHistoryByUser(nguoiDungId, metricId, range);
  return { success: true, data };
};

export const handleGetHistory = async (deviceId, metricId) => {
  const data = await getHealthHistory(deviceId, metricId);
  return { success: true, data };
};

export const handleGetReport = async (user, quanHeId, type) => {
  const userId = user?.NguoiDung_ID || user?.nguoidung_id;
  const data = await getHealthReport(userId, quanHeId, type);
  return { success: true, data };
};
