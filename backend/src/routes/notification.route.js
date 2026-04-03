import express from "express";
import * as notificationService from "../services/notification.service.js";
import { auth } from "../middlewares/auth.middleware.js";

const router = express.Router();

router.post("/test", auth, async (req, res) => {
  try {
    const response = await notificationService.handleTestNotification(req.user.nguoidung_id);
    res.json(response);
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.post("/broadcast", async (req, res) => {
  try {
    const response = await notificationService.handleBroadcast();
    res.json(response);
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.get("/user", auth, async (req, res) => {
  try {
    const response = await notificationService.handleGetAlerts(req.user.nguoidung_id);
    res.json(response);
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.post("/read/:id", auth, async (req, res) => {
  try {
    const response = await notificationService.handleMarkAsRead(req.user.nguoidung_id, req.params.id);
    res.json(response);
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.delete("/:id", auth, async (req, res) => {
  try {
    const response = await notificationService.handleDeleteNotification(req.user.nguoidung_id, req.params.id);
    res.json(response);
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.get("/alerts", auth, async (req, res) => {
  try {
    const response = await notificationService.handleGetAlerts(req.user.nguoidung_id);
    res.json(response);
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

router.get("/admin/alerts", async (req, res) => {
  try {
    const response = await notificationService.handleGetAdminAlerts();
    res.json(response);
  } catch (err) {
    console.error("ADMIN ALERT ERROR:", err);
    res.status(500).json({ success: false, message: err.message });
  }
});

export default router;