import express from "express";
import {
  getSettings,
  updateSetting
} from "../repos/settings.repo.js";

const router = express.Router();

/* =========================
   GET SETTINGS
   /api/settings/:userId
========================= */
import { auth } from "../middlewares/auth.middleware.js";

router.get("/", auth, async (req, res) => {
  const userId = req.user.NguoiDung_ID;

  const data = await getSettings(userId);
  res.json(data);
});

router.put("/", auth, async (req, res) => {
  const userId = req.user.NguoiDung_ID;
  const { key, value } = req.body;

  await updateSetting(userId, key, value);

  res.json({ success: true });
});

/* =========================
   UPDATE SETTING
   PUT /api/settings
========================= */
router.put("/", async (req, res) => {
  try {
    const { userId, key, value } = req.body;

    await updateSetting(userId, key, value);

    res.json({ success: true });
  } catch (err) {
    console.error("UPDATE SETTINGS ERROR:", err);
    res.status(500).json({ message: err.message });
  }
});

export default router;