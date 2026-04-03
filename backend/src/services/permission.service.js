import { getAllPermissions, getPermissionConfigs, savePermissionConfig, getSharedConversation, checkPermissionAccess } from "../repos/permission.repo.js";
import { getHealthReport } from "../repos/healthMetric.repo.js";

export const handleGetAllPermissions = async () => {
  const data = await getAllPermissions();
  return { success: true, data };
};

export const handleGetPermissionConfigs = async (userId, quanHeId) => {
  if (!quanHeId) throw new Error("Thiếu QuanHeGiamHo_ID");
  if (!(await checkPermissionAccess(userId, quanHeId))) {
    const error = new Error("ACCESS_DENIED");
    error.status = 403;
    throw error;
  }
  const data = await getPermissionConfigs(quanHeId);
  return { success: true, data };
};

export const handleSavePermissionConfig = async (userId, quanHeId, quyenId, active) => {
  if (!quanHeId || !quyenId) throw new Error("Thiếu dữ liệu cấu hình");
  if (!(await checkPermissionAccess(userId, quanHeId))) {
    const error = new Error("ACCESS_DENIED");
    error.status = 403;
    throw error;
  }
  await savePermissionConfig(quanHeId, quyenId, active);
  return { success: true, message: "Cập nhật quyền thành công" };
};

export const handleGetSharedConversation = async (userId, quanHeId) => {
  if (!(await checkPermissionAccess(userId, quanHeId))) {
    const error = new Error("ACCESS_DENIED");
    error.status = 403;
    throw error;
  }
  const data = await getSharedConversation(quanHeId);
  return { success: true, data };
};

export const handleGetHealthReport = async (userId, quanHeId, type) => {
  if (!quanHeId) throw new Error("Thiếu QuanHeGiamHo_ID");
  if (!(await checkPermissionAccess(userId, quanHeId))) {
    const error = new Error("ACCESS_DENIED");
    error.status = 403;
    throw error;
  }
  const data = await getHealthReport(userId, quanHeId, type);
  return { success: true, data };
};
