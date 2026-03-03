import express from "express";
import {
  requestRegisterOtp,
  requestLoginOtp,
  verifyOtp,
  changePhone,
  getLoginHistory,  
   saveFcmToken, 
} from "../repos/auth.repo.js";
import { auth } from "../middlewares/auth.middleware.js";
import { sendTestPush } from "../repos/auth.repo.js";

const router = express.Router();

/* =========================
   REGISTER – REQUEST OTP
========================= */
router.post("/register/request-otp", async (req, res) => {
  try {
    const { phone } = req.body;
    if (!phone) throw new Error("Thiếu số điện thoại");

    await requestRegisterOtp(phone);

    res.json({
      success: true,
      message: "OTP đăng ký đã được gửi",
    });
  } catch (e) {
    res.status(400).json({
      success: false,
      message: e.message,
    });
  }
});

/* =========================
   LOGIN – REQUEST OTP
========================= */
router.post("/login/request-otp", async (req, res) => {
  try {
    const { phone } = req.body;
    if (!phone) throw new Error("Thiếu số điện thoại");

    await requestLoginOtp(phone);

    res.json({
      success: true,
      message: "OTP đăng nhập đã được gửi",
    });
  } catch (e) {
    res.status(400).json({
      success: false,
      message: e.message,
    });
  }
});

/* =========================
   VERIFY OTP (CHUNG)
========================= */
router.post("/verify-otp", async (req, res) => {
  try {
    const { phone, otp } = req.body;
    if (!phone || !otp) {
      throw new Error("Thiếu số điện thoại hoặc OTP");
    }

    const result = await verifyOtp(phone, otp, req);
    res.json(result);
  } catch (e) {
    res.status(401).json({
      success: false,
      message: e.message,
    });
  }
});

/* =========================
   CHANGE PHONE
========================= */
router.post("/change-phone", auth, async (req, res) => {
  try {
    const { phone } = req.body;
    const userId = req.user.NguoiDung_ID;

    await changePhone(userId, phone);

    res.json({ success: true });
  } catch (e) {
    res.status(400).json({
      success: false,
      message: e.message,
    });
  }
});

/* =========================
   LOGIN HISTORY (🔥 THÊM)
========================= */
router.get("/login-history", auth, async (req, res) => {
  try {
    const userId = req.user.NguoiDung_ID;

    const data = await getLoginHistory(userId);

    res.json({
      success: true,
      data,
    });
  } catch (e) {
    res.status(400).json({
      success: false,
      message: e.message,
    });
  }
});
router.post("/save-fcm-token", auth, async (req, res) => {
  try {
    const userId = req.user.NguoiDung_ID;
    const { fcmToken } = req.body;

    if (!fcmToken) {
      return res.status(400).json({ success: false });
    }

    await saveFcmToken(userId, fcmToken);

    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});
router.post("/test-push", auth, async (req, res) => {
  try {
    const userId = req.user.NguoiDung_ID;

    await sendTestPush(userId);

    res.json({ success: true });
  } catch (e) {
    res.status(400).json({
      success: false,
      message: e.message,
    });
  }
});
export default router;
