import {
  firebasePhoneLogin,
  changePhone,
  adminLogin,
  getLoginHistory,
  saveFcmToken,
  sendTestPush,
  removeFcmToken,
  changeAdminPassword
} from "../repos/auth.repo.js";

export const handleAdminChangePassword = async (taikhoanId, oldPassword, newPassword) => {
  if (!oldPassword || !newPassword) throw new Error("Thiếu mật khẩu cũ hoặc mật khẩu mới");
  return await changeAdminPassword(taikhoanId, oldPassword, newPassword);
};

export const handleAdminLogin = async (phone, password, req) => {
  if (!phone || !password) throw new Error("Thiếu số điện thoại hoặc mật khẩu");
  return await adminLogin(phone, password, req);
};
export const handleFirebasePhoneLogin = async (idToken, req, fcmToken) => {
  if (!idToken) throw new Error("Thiếu Firebase ID token");

  const result = await firebasePhoneLogin(idToken, req);

  if (fcmToken) {
    await saveFcmToken(result.user.nguoidung.nguoidung_id, fcmToken);
  }

  return result;
};

export const handleChangePhone = async (userId, phone) => {
  await changePhone(userId, phone);
  return { success: true };
};

export const handleGetLoginHistory = async (taikhoanId) => {
  const data = await getLoginHistory(taikhoanId);
  return { success: true, data };
};

export const handleSendTestPush = async (userId) => {
  await sendTestPush(userId);
  return { success: true };
};

export const handleRemoveFcmToken = async (fcmToken) => {
  await removeFcmToken(fcmToken);
  return { success: true };
};
