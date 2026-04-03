import express from "express";
import * as settingsService from "../services/settings.service.js";
import { auth } from "../middlewares/auth.middleware.js";

const router = express.Router();

router.get("/", auth, async (req, res) => {
  try {
    const response = await settingsService.handleGetSettings(req.user.nguoidung_id);
    res.json(response);
  } catch (err) {
    console.error("GET SETTINGS ERROR:", err);
    res.status(500).json({ message: err.message });
  }
});

router.put("/", auth, async (req, res) => {
  try {
    const response = await settingsService.handleUpdateSetting(req.user.nguoidung_id, req.body.key, req.body.value);
    res.json(response);
  } catch (err) {
    console.error("UPDATE SETTINGS ERROR:", err);
    res.status(500).json({ message: err.message });
  }
});

export default router;