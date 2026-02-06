import express from "express";
import {
  sendInviteByPhone,
  acceptInvite,
  rejectInvite,
  getInvites,
  findUserByPhone 
} from "../repos/invite.repo.js";
import { auth } from "../middlewares/auth.middleware.js";

const router = express.Router();

/* =========================
   GỬI LỜI MỜI BẰNG SĐT
========================= */
router.post("/by-phone", auth, async (req, res) => {
  try {
    const { phone } = req.body;
    const fromUserId = req.user.NguoiDung_ID; // 🔥 ĐÃ CÓ

    if (!phone) throw new Error("Thiếu số điện thoại");

    await sendInviteByPhone(fromUserId, phone);

    res.json({ success: true, message: "Đã gửi lời mời" });
  } catch (e) {
    res.status(400).json({
      success: false,
      message: e.message,
    });
  }
});

router.get("/find-by-phone", async (req, res) => {
  try {
    const { phone } = req.query;
    if (!phone) throw new Error("Thiếu số điện thoại");

    const user = await findUserByPhone(phone);
    if (!user) {
      return res.json({ success: true, data: null });
    }

    res.json({ success: true, data: user });
  } catch (e) {
    res.status(400).json({
      success: false,
      message: e.message,
    });
  }
});


/* =========================
   CHẤP NHẬN
========================= */
router.post("/accept", auth, async (req, res) => {
  try {
    const { loiMoiId } = req.body;
    if (!loiMoiId) throw new Error("Thiếu ID lời mời");

    await acceptInvite(loiMoiId);

    res.json({ success: true, message: "Đã chấp nhận lời mời" });
  } catch (e) {
    res.status(400).json({
      success: false,
      message: e.message,
    });
  }
});

/* =========================
   TỪ CHỐI
========================= */
router.post("/reject", auth, async (req, res) => {
  try {
    const { loiMoiId } = req.body;
    if (!loiMoiId) throw new Error("Thiếu ID lời mời");

    await rejectInvite(loiMoiId);

    res.json({ success: true, message: "Đã từ chối lời mời" });
  } catch (e) {
    res.status(400).json({
      success: false,
      message: e.message,
    });
  }
});

/* =========================
   DANH SÁCH LỜI MỜI
========================= */
router.get("/incoming", auth, async (req, res) => {
  try {
    const userId = req.user?.NguoiDung_ID;
    const data = await getInvites(userId);

    res.json({ success: true, data });
  } catch (e) {
    res.status(400).json({
      success: false,
      message: e.message,
    });
  }
});

export default router;
