import express from "express";
import * as authService from "../services/auth.service.js";
import { auth } from "../middlewares/auth.middleware.js";

const router = express.Router();

router.post("/register/request-otp", async (req, res) => {
  try {
    const { phone } = req.body;
    const response = await authService.handleRequestRegisterOtp(phone);
    res.json(response);
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

router.post("/login/request-otp", async (req, res) => {
  try {
    const { phone } = req.body;
    const response = await authService.handleRequestLoginOtp(phone);
    res.json(response);
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

router.post("/verify-otp", async (req, res) => {
  try {
    const { phone, otp, fcmToken, deviceId } = req.body;
    const response = await authService.handleVerifyOtp(phone, otp, req, deviceId, fcmToken);
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

router.get("/login-history", auth, async (req, res) => {
  try {
    const response = await authService.handleGetLoginHistory(req.user.nguoidung_id);
    res.json(response);
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
