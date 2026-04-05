import { getAllHealthMetrics, createHealthMetric, getLatestHealthDataByDevice, getLatestHealthDataByUser, getHealthHistory, getHealthHistoryByUser, getHealthReport, ensureDeviceForUser, saveMultipleHealthData, insertAIInsight, getLatestAIInsight, getAIInsightByDate } from "../repos/healthMetric.repo.js";
import { sendNotification } from "../repos/notification.repo.js";
import { callSelfEvolutionAI } from "./aiClient.js";
import { getCurrentVNHour, getVNDateString } from "../utils/time.js";


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

  const vnHour = getCurrentVNHour();
  const today = getVNDateString();

  // 🔥 check đã có AI hôm nay chưa
  const existingInsight = await getAIInsightByDate(nguoiDungId, today);

  // =========================
  // CASE 1: trước 9h
  // =========================
  if (vnHour < 9) {
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

function mapCompareTitleUser(status) {
  switch (status) {
    case "tốt":
      return "Chỉ số hôm nay tốt hơn hôm qua";
    case "xấu":
      return "Chỉ số hôm nay giảm so với hôm qua";
    default:
      return "Tình trạng của bạn đang ổn định";
  }
}

function mapCompareTitleGuardian(status) {
  switch (status) {
    case "tốt":
      return "Chỉ số của người thân cải thiện";
    case "xấu":
      return "Chỉ số của người thân giảm";
    default:
      return "Tình trạng của người thân ổn định";
  }
}

export const createDailyCompareNotification = async (userId, aiEvaluation) => {
  if (!aiEvaluation || !aiEvaluation.compare) return;

  const status = aiEvaluation.status || "bình thường";
  const message = aiEvaluation.message || "";
  const advice = aiEvaluation.advice || "";
  const compareText = formatCompare(aiEvaluation.compare);

  const titleSelf = mapCompareTitleUser(status);
  const titleGuardian = mapCompareTitleGuardian(status);

  // 🔥 NEW: Gộp message, compare và advice vào body
  const body = `${message}\n\n${compareText}\n\n💡 Lời khuyên: ${advice}`.trim();

  try {
    await sendNotification(userId, titleSelf, body, 1, 'DAILY_COMPARE', titleGuardian);
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

export const handleGetLatestAIInsight = async (user) => {
  const nguoiDungId = user?.NguoiDung_ID || user?.nguoidung_id;
  if (!nguoiDungId) throw new Error("Chưa đăng nhập");

  const data = await getLatestAIInsight(nguoiDungId);
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
