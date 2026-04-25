import express from "express";
import * as chatService from "../services/chat.service.js";
import multer from "multer";
import path from "path";
const router = express.Router();
const storage = multer.diskStorage({
  destination: "uploads/",
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname || ".jpg");
    cb(null, `chat_${Date.now()}${ext}`);
  },
});

const upload = multer({ storage });
router.post("/", async (req, res) => {
  try {
    const {
      message = "",
      userId,
      digitalId,
      hoiThoaiId,
      loaiTinNhan = "text",
      mediaUrl = null,
    } = req.body;

    const response = await chatService.handlePostChat(
      message,
      userId,
      digitalId,
      hoiThoaiId,
      loaiTinNhan,
      mediaUrl
    );
    res.json(response);
  } catch (error) {
    console.error("CHAT ERROR:", error);
    res.status(error.message === "Thiếu dữ liệu" ? 400 : 500).json({ success: false, message: error.message });
  }
});

router.get("/history/:userId", async (req, res) => {
  try {
    const response = await chatService.handleGetHistory(req.params.userId);
    res.json(response);
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.get("/messages/:hoiThoaiId", async (req, res) => {
  try {
    const response = await chatService.handleGetMessages(req.params.hoiThoaiId);
    res.json(response);
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.delete("/conversation/:hoiThoaiId", async (req, res) => {
  try {
    const response = await chatService.handleDeleteConversation(req.params.hoiThoaiId);
    res.json(response);
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.get("/conversations", async (req, res) => {
  try {
    const response = await chatService.handleGetConversations();
    res.json(response);
  } catch (err) {
    console.error("CONVERSATIONS ERROR:", err);
    res.status(500).json({ success: false, message: err.message });
  }
});
router.post("/upload-image", upload.single("image"), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "Thiếu file ảnh",
      });
    }

    const mediaUrl = `${req.protocol}://${req.get("host")}/uploads/${req.file.filename}`;

    res.json({
      success: true,
      mediaUrl,
    });
  } catch (error) {
    console.error("UPLOAD IMAGE ERROR:", error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});
export default router;
