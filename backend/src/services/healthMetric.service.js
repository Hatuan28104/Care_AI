import { getAllHealthMetrics, createHealthMetric, getLatestHealthDataByDevice, getLatestHealthDataByUser, getHealthHistory, getHealthHistoryByUser, getHealthReport, ensureDeviceForUser, saveMultipleHealthData, insertAIInsight, getLatestAIInsight, getAIInsightByDate, getStressInputData, saveHealthData } from "../repos/healthMetric.repo.js";
import { sendNotification } from "../repos/notification.repo.js";
import { callSelfEvolutionAI, callStressAI } from "./aiClient.js";
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
  return { success: true, data: { nguondulieu_id: thietBiId } };
};

export const handleSaveData = async (user, body) => {
  const nguoiDungId = user?.NguoiDung_ID || user?.nguoidung_id;
  if (!nguoiDungId) throw new Error("Chưa đăng nhập");

const nguondulieu_id = body.nguondulieu_id ?? body.NguonDuLieu_ID ?? null;
  await saveMultipleHealthData({
    ...body,
    nguoidung_id: nguoiDungId,
    nguondulieu_id,
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

  if (aiAnalysis && aiAnalysis.sosanh) {
    await insertAIInsight(nguoiDungId, aiAnalysis);
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
      return "Chỉ số của người thân tốt hơn hôm qua";
    case "xấu":
      return "Chỉ số của người thân giảm";
    default:
      return "Tình trạng của người thân ổn định";
  }
}

export const createDailyCompareNotification = async (userId, aiEvaluation) => {
  if (!aiEvaluation || !aiEvaluation.sosanh) return;

  const trangthai = aiEvaluation.trangthai || "bình thường";
  const thongdiep = aiEvaluation.thongdiep || "";
  const loikhuyen = aiEvaluation.loikhuyen || "";
  const sosanhText = formatSoSanh(aiEvaluation.sosanh);

  const titleSelf = mapCompareTitleUser(trangthai);
  const titleGuardian = mapCompareTitleGuardian(trangthai);

  const body = `${thongdiep}\n\n${sosanhText}\n\n💡 Lời khuyên: ${loikhuyen}`.trim();

  try {
    await sendNotification(userId, titleSelf, body, 1, 'DAILY_COMPARE', titleGuardian);
  } catch (err) {
    console.error(err.message);
  }
};

function formatSoSanh(sosanh) {
  if (!sosanh) return "Không có dữ liệu so sánh.";
  if (typeof sosanh === 'string') return sosanh;

  const lines = [];
  for (const value of Object.values(sosanh)) {
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

export const handleAnalyzeStress = async (user) => {
  const nguoiDungId = user?.NguoiDung_ID || user?.nguoidung_id;
  if (!nguoiDungId) throw new Error("Chưa đăng nhập");

  // 1. Lấy dữ liệu đầu vào (HRV, HR, Sleep, Steps) dựa trên người dùng
  const inputData = await getStressInputData(nguoiDungId);

  // 2. Gọi AI Stress
  const aiRes = await callStressAI(nguoiDungId, inputData);
  if (!aiRes || aiRes.stress === undefined) {
    throw new Error("Không nhận được kết quả từ AI Stress");
  }

  const stressScore = aiRes.stress;

  // 3. Lưu vào bảng dulieusuckhoe
  console.log(`[Stress] Saving for user ${nguoiDungId}, score ${stressScore}`);

  await saveHealthData({
    nguoidung_id: nguoiDungId,
    loaichiso_id: "CS016",
    giatri: stressScore,
    nguondulieu_id: null // Stress là chỉ số tính toán, không gắn với 1 thiết bị cụ thể
  });

  return { 
    success: true, 
    data: { 
      stress: stressScore,
      thoigian: new Date().toISOString()
    } 
  };
};
