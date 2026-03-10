import express from "express";
import {
  handleChat,
  getChatHistory,
  getMessages,
  deleteConversation,
  renameConversation,
} from "../repos/chat.repo.js";

const router = express.Router();

/* =========================
   CHAT BOT
========================= */

router.post("/", async (req, res) => {
  try {
    const { message, userId, digitalId, hoiThoaiId } = req.body;

    /* VALIDATE INPUT */

    if (!message?.trim()) {
      return res.status(400).json({
        success: false,
        message: "Thiếu nội dung tin nhắn",
      });
    }

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "Thiếu userId",
      });
    }

    if (!digitalId) {
      return res.status(400).json({
        success: false,
        message: "Thiếu digitalId",
      });
    }

    /* CALL CHAT SERVICE */

    const result = await handleChat(
      message.trim(),
      userId,
      digitalId,
      hoiThoaiId || null,
    );

    return res.json(result);
  } catch (error) {
    console.error("CHAT ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Server error",
    });
  }
});

/* =========================
   HISTORY CHAT
========================= */

router.get("/history/:userId", async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "Thiếu userId",
      });
    }

    const histories = await getChatHistory(userId);

    return res.json({
      success: true,
      data: histories,
    });
  } catch (error) {
    console.error("HISTORY ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Server error",
    });
  }
});

/* =========================
   GET MESSAGES
========================= */

router.get("/messages/:hoiThoaiId", async (req, res) => {
  try {
    const { hoiThoaiId } = req.params;

    if (!hoiThoaiId) {
      return res.status(400).json({
        success: false,
        message: "Thiếu hoiThoaiId",
      });
    }

    const messages = await getMessages(hoiThoaiId);

    return res.json({
      success: true,
      data: messages,
    });
  } catch (error) {
    console.error("MESSAGES ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Server error",
    });
  }
});

/* =========================
   DELETE CONVERSATION
========================= */

router.delete("/conversation/:hoiThoaiId", async (req, res) => {
  try {
    const { hoiThoaiId } = req.params;

    if (!hoiThoaiId) {
      return res.status(400).json({
        success: false,
        message: "Thiếu hoiThoaiId",
      });
    }

    await deleteConversation(hoiThoaiId);

    return res.json({
      success: true,
    });
  } catch (error) {
    console.error("DELETE ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Server error",
    });
  }
});

/* =========================
   RENAME CONVERSATION
========================= */

router.put("/conversation/rename", async (req, res) => {
  try {
    const { hoiThoaiId, title } = req.body;

    if (!hoiThoaiId || !title?.trim()) {
      return res.status(400).json({
        success: false,
        message: "Thiếu dữ liệu rename",
      });
    }

    await renameConversation(hoiThoaiId, title.trim());

    return res.json({
      success: true,
    });
  } catch (error) {
    console.error("RENAME ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Server error",
    });
  }
});

export default router;
