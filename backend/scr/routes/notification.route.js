import express from "express";
import {
  sendNotification,
  sendToAll,
  markAsRead,
  deleteNotification,
  getAlerts
} from "../repos/notification.repo.js";
import { auth } from "../middlewares/auth.middleware.js";

const router = express.Router();

/* ===== TEST ===== */
router.post("/test", auth, async (req, res) => {
  const userId = req.user.nguoidung_id;

  await sendNotification(
    userId,
    "Test tự động 🔥",
    "Backend tự gửi nè!"
  );

  res.json({ success: true });
});

/* ===== BROADCAST ===== */
router.post("/broadcast", async (req, res) => {
  await sendToAll(
    "Broadcast 🔥",
    "Test gửi cho tất cả user"
  );

  res.json({ success: true });
});

/* =========================
   GET NOTIFICATION (CHÍNH USER)
========================= */
router.get("/user", auth, async (req, res) => {
  try {
    const userId = req.user.nguoidung_id;

    const data = await getAlerts(userId);

    res.json({
      success: true,
      data
    });

  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message
    });
  }
});

/* =========================
   MARK AS READ
========================= */
router.post("/read/:id", auth, async (req, res) => {
  try {
    const userId = req.user.nguoidung_id;
    const { id } = req.params;

    await markAsRead(id, userId);

    res.json({ success: true });

  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message
    });
  }
});

/* =========================
   DELETE
========================= */
router.delete("/:id", auth, async (req, res) => {
  try {
    const userId = req.user.nguoidung_id;
    const { id } = req.params;

    await deleteNotification(id, userId);

    res.json({ success: true });

  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message
    });
  }
});

/* =========================
   GET ALERTS (CANH BAO)
========================= */
router.get("/alerts", auth, async (req, res) => {
  try {
    const userId = req.user.nguoidung_id;
    const data = await getAlerts(userId);

    res.json({
      success: true,
      data
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

export default router;