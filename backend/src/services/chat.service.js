import { handleChat, getChatHistory, getMessages, deleteConversation, getConversationsStats } from "../repos/chat.repo.js";

export const handlePostChat = async (message, userId, digitalId, hoiThoaiId) => {
  if (!message || !userId || !digitalId) throw new Error("Thiếu dữ liệu");

  let conversationId = null;
  if (hoiThoaiId && hoiThoaiId !== "" && hoiThoaiId !== "null") {
    conversationId = hoiThoaiId;
  }

  const result = await handleChat(message.trim(), userId, digitalId, conversationId);
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
