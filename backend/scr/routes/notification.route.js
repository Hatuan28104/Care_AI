import express from "express";
import { sendNotification } from "../services/notification.service.js";
import { sendToAll } from "../services/notification.service.js";
const router = express.Router();

router.post("/test", async (req, res) => {
  const { userId } = req.body;

  await sendNotification(
    userId,
    "Test tự động 🔥",
    "Backend tự gửi nè!"
  );

  res.json({ success: true });
});
router.post("/broadcast", async (req, res) => {
  await sendToAll(
    "Broadcast 🔥",
    "Test gửi cho tất cả user"
  );

  res.json({ success: true });
});
export default router;