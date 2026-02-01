import express from "express";
import {
  requestRegisterOtp,
  requestLoginOtp,
  verifyOtp,
} from "../repos/auth.repo.js";

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

    const result = await verifyOtp(phone, otp);
    res.json(result);
  } catch (e) {
    res.status(401).json({
      success: false,
      message: e.message,
    });
  }
});

export default router;
