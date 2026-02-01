import express from "express";
import { requestOtp, verifyOtp } from "../repos/auth.repo.js";

const router = express.Router();

/**
 * =============================
 * GỬI OTP
 * POST /auth/request-otp
 * body: { phone }
 * =============================
 */
router.post("/request-otp", async (req, res) => {
  try {
    const { phone } = req.body;

    if (!phone) {
      return res.status(400).json({
        success: false,
        message: "Thiếu số điện thoại",
      });
    }

    await requestOtp(phone);

    res.json({
      success: true,
      message: "OTP đã được gửi",
    });
  } catch (e) {
    res.status(400).json({
      success: false,
      message: e.message,
    });
  }
});

/**
 * =============================
 * XÁC THỰC OTP
 * POST /auth/verify-otp
 * body: { phone, otp }
 * =============================
 */
router.post("/verify-otp", async (req, res) => {
  try {
    const { phone, otp } = req.body;

    if (!phone || !otp) {
      return res.status(400).json({
        success: false,
        message: "Thiếu số điện thoại hoặc OTP",
      });
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
