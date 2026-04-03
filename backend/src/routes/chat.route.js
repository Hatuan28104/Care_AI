import express from "express";
import * as chatService from "../services/chat.service.js";

const router = express.Router();

router.post("/", async (req, res) => {
  try {
    const { message, userId, digitalId, hoiThoaiId } = req.body;
    const response = await chatService.handlePostChat(message, userId, digitalId, hoiThoaiId);
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

export default router;
