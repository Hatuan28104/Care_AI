import { getAllHealthMetrics, createHealthMetric, getLatestHealthDataByDevice, getLatestHealthDataByUser, getHealthHistory, getHealthHistoryByUser, getHealthReport, ensureDeviceForUser, saveMultipleHealthData, insertAIInsight, getLatestAIInsight, getAIInsightByDate } from "../repos/healthMetric.repo.js";
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

  if (hour < 9) {
    return { 
      success: true, 
      message: "Đã lưu dữ liệu, AI sẽ cập nhật sau 9h"
    };
  }

  // Sau 9h
  const existingInsight = await getAIInsightByDate(nguoiDungId, today);
  if (existingInsight) {
    return { 
      success: true, 
      message: "Đã lưu dữ liệu sức khỏe",
      ai_evaluation: existingInsight
    };
  }

  // Gọi AI Inference lấy dự đoán
  const aiAnalysis = await callSelfEvolutionAI(nguoiDungId, body);
  console.log("[handleSaveData] AI response status:", aiAnalysis?.status, "user:", nguoiDungId);

  if (aiAnalysis && aiAnalysis.status) {
    await insertAIInsight(nguoiDungId, aiAnalysis, today);
  }

  return { 
    success: true, 
    message: "Đã lưu dữ liệu sức khỏe",
    ai_evaluation: aiAnalysis
  };
};

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

export const handleGetLatestAIInsight = async (user) => {
  const nguoiDungId = user?.NguoiDung_ID || user?.nguoidung_id;
  if (!nguoiDungId) throw new Error("Chưa đăng nhập");

  const data = await getLatestAIInsight(nguoiDungId);
  if (!data) {
    return { success: false, message: "AI chưa cập nhật (sau 9h)" };
  }

  return { success: true, data };
};
