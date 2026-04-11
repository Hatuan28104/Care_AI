import {
  requestRegisterOtp, requestLoginOtp, verifyOtp, changePhone, adminLogin,
  getLoginHistory, saveFcmToken, sendTestPush, removeFcmToken
} from "../repos/auth.repo.js";

export const handleRequestRegisterOtp = async (phone) => {
  if (!phone) throw new Error("Thiếu số điện thoại");
  await requestRegisterOtp(phone);
  return { success: true, message: "OTP đăng ký đã được gửi" };
};

export const handleRequestLoginOtp = async (phone) => {
  if (!phone) throw new Error("Thiếu số điện thoại");
  await requestLoginOtp(phone);
  return { success: true, message: "OTP đăng nhập đã được gửi" };
};

export const handleAdminLogin = async (phone, password, req) => {
  if (!phone || !password) throw new Error("Thiếu số điện thoại hoặc mật khẩu");
  return await adminLogin(phone, password, req);
};

export const handleVerifyOtp = async (phone, otp, req, deviceId, fcmToken) => {
  if (!phone || !otp) throw new Error("Thiếu số điện thoại hoặc OTP");
  const result = await verifyOtp(phone, otp, req, deviceId);
  if (fcmToken) saveFcmToken(result.user.nguoidung.nguoidung_id, fcmToken);
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
