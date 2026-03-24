import express from "express";
import { 
  requestRegisterOtp,
  requestLoginOtp,
  verifyOtp,
  changePhone,
  getLoginHistory,
  saveFcmToken,
  sendTestPush,
  removeFcmToken   
} from "../repos/auth.repo.js";
import { auth } from "../middlewares/auth.middleware.js";

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
    const { phone, otp, fcmToken, deviceId } = req.body;
    if (!phone || !otp) {
      throw new Error("Thiếu số điện thoại hoặc OTP");
    }

    const result = await verifyOtp(phone, otp, req, deviceId);
    if (fcmToken) {
      saveFcmToken(result.user.nguoidung.nguoidung_id, fcmToken);
    }
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
    const userId = req.user.nguoidung_id;

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
    const userId = req.user.nguoidung_id;

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

router.post("/test-push", auth, async (req, res) => {
  try {
    const userId = req.user.nguoidung_id;

    await sendTestPush(userId);

    res.json({ success: true });
  } catch (e) {
    res.status(400).json({
      success: false,
      message: e.message,
    });
  }
});
router.post("/remove-fcm-token", auth, async (req, res) => {
    try {
    const { fcmToken } = req.body;

    await removeFcmToken(fcmToken);

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ success: false });
  }
});
export default router;
