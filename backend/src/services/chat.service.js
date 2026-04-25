import { handleChat, getChatHistory, getMessages, deleteConversation, getConversationsStats } from "../repos/chat.repo.js";

export const handlePostChat = async (
  message,
  userId,
  digitalId,
  hoiThoaiId,
  loaiTinNhan = "text",
  mediaUrl = null
) => {
  const cleanMessage = (message || "").trim();
  const type = loaiTinNhan || "text";

  if (!userId || !digitalId) throw new Error("Thiếu dữ liệu");

  if (type === "text" && !cleanMessage) {
    throw new Error("Thiếu dữ liệu");
  }

  if (type === "image" && !mediaUrl) {
    throw new Error("Image phải có mediaUrl");
  }

  let conversationId = null;
  if (hoiThoaiId && hoiThoaiId !== "" && hoiThoaiId !== "null") {
    conversationId = hoiThoaiId;
  }

  const result = await handleChat(
    cleanMessage,
    userId,
    digitalId,
    conversationId,
    type,
    mediaUrl
  );

  return result;
};

export const handleGetHistory = async (userId) => {
  const histories = await getChatHistory(userId);
  return { success: true, data: histories };
};

export const handleGetMessages = async (hoiThoaiId) => {
  const messages = await getMessages(hoiThoaiId);
  return { success: true, data: messages };
};

export const handleDeleteConversation = async (hoiThoaiId) => {
  await deleteConversation(hoiThoaiId);
  return { success: true };
};

export const handleGetConversations = async () => {
  const data = await getConversationsStats();
  return { success: true, data };
};
