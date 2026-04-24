import express from "express";
import * as authService from "../services/auth.service.js";
import { auth, requireAdmin } from "../middlewares/auth.middleware.js";

const router = express.Router();
router.post("/firebase-login", async (req, res) => {
  try {
    const { idToken, fcmToken } = req.body;

    const response = await authService.handleFirebasePhoneLogin(
      idToken,
      req,
      fcmToken
    );

    res.json(response);
  } catch (e) {
    res.status(401).json({ success: false, message: e.message });
  }
});
router.post("/admin/login", async (req, res) => {
  try {
    const phone = req.body?.phone ?? req.body?.sodienthoai;
    const password = req.body?.password ?? req.body?.matkhau;
    const response = await authService.handleAdminLogin(phone, password, req);
    res.json(response);
  } catch (e) {
    res.status(401).json({ success: false, message: e.message });
  }
});

router.post("/change-phone", auth, async (req, res) => {
  try {
    const response = await authService.handleChangePhone(req.user.nguoidung_id, req.body.phone);
    res.json(response);
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

router.post("/admin/change-password", auth, requireAdmin, async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;
    const response = await authService.handleAdminChangePassword(req.user.taikhoan_id, oldPassword, newPassword);
    res.json({ success: true, message: "Đổi mật khẩu thành công" });
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

router.get("/login-history", auth, async (req, res) => {
  try {
    const response = await authService.handleGetLoginHistory(req.user.taikhoan_id); res.json(response);
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

router.post("/test-push", auth, async (req, res) => {
  try {
    const response = await authService.handleSendTestPush(req.user.nguoidung_id);
    res.json(response);
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

router.post("/remove-fcm-token", auth, async (req, res) => {
  try {
    const response = await authService.handleRemoveFcmToken(req.body.fcmToken);
    res.json(response);
  } catch (err) {
    res.status(500).json({ success: false });
  }
});

export default router;
