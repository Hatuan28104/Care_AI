import express from "express";
import multer from "multer";
import path from "path";
import * as profileService from "../services/profile.service.js";

const router = express.Router();

const storage = multer.diskStorage({
  destination: path.join(process.cwd(), "uploads/avatars"),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${req.params.id}-${Date.now()}${ext}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 2 * 1024 * 1024 },
});

router.get("/", async (req, res) => {
  try {
    const response = await profileService.handleGetAllUsers();
    res.json(response);
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

router.get("/dashboard/users", async (req, res) => {
  try {
    const response = await profileService.handleGetUserStats();
    res.json(response);
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.get("/:id", async (req, res) => {
  try {
    const response = await profileService.handleGetProfileById(req.params.id);
    res.json(response);
  } catch (e) {
    res.status(e.message === "Chưa có hồ sơ" ? 404 : 500).json({ success: false, message: e.message });
  }
});

router.put("/:id", upload.single("avatar"), async (req, res) => {
  try {
    const response = await profileService.handleUpdateProfile(req.params.id, req.file, req.body);
    res.json(response);
  } catch (e) {
    res.status(400).json({ success: false, message: e.message, errors: e.errors || null });
  }
});

router.delete("/:id", async (req, res) => {
  try {
    const response = await profileService.handleDeleteUser(req.params.id);
    res.json(response);
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

export default router;