import express from "express";
import {
  handleChat,
  getChatHistory,
  getMessages,
  deleteConversation,
  getConversationsStats   
} from "../repos/chat.repo.js";

const router = express.Router();

/* ================= CHAT ================= */

router.post("/", async (req, res) => {
  try {
    const { message, userId, digitalId, hoiThoaiId } = req.body;

    if (!message || !userId || !digitalId) {
      return res.status(400).json({
        success: false,
        message: "Thiếu dữ liệu",
      });
    }

    let conversationId = null;

    if (hoiThoaiId && hoiThoaiId !== "" && hoiThoaiId !== "null") {
      conversationId = hoiThoaiId;
    }

    const result = await handleChat(
      message.trim(),
      userId,
      digitalId,
      conversationId,
    );

    res.json(result);
  } catch (error) {
    console.error("CHAT ERROR:", error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

/* ================= HISTORY ================= */

router.get("/history/:userId", async (req, res) => {
  try {
    const histories = await getChatHistory(req.params.userId);

    res.json({
      success: true,
      data: histories,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

/* ================= GET MESSAGES ================= */

router.get("/messages/:hoiThoaiId", async (req, res) => {
  try {
    const messages = await getMessages(req.params.hoiThoaiId);

    res.json({
      success: true,
      data: messages,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

/* ================= DELETE ================= */

router.delete("/conversation/:hoiThoaiId", async (req, res) => {
  try {
    await deleteConversation(req.params.hoiThoaiId);

    res.json({
      success: true,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});
router.get("/conversations", async (req, res) => {
  try {
    const data = await getConversationsStats();

    res.json({
      success: true,
      data
    });

  } catch (err) {
    console.error("CONVERSATIONS ERROR:", err);

    res.status(500).json({
      success: false,
      message: err.message
    });
  }
});
export default router;
