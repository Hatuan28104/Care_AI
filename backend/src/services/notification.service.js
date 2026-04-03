import { sendNotification, sendToAll, markAsRead, deleteNotification, getAlerts, getAdminAlerts } from "../repos/notification.repo.js";

export const handleTestNotification = async (userId) => {
  await sendNotification(userId, "Test tự động 🔥", "Backend tự gửi nè!");
  return { success: true };
};

export const handleBroadcast = async () => {
  await sendToAll("Broadcast 🔥", "Test gửi cho tất cả user");
  return { success: true };
};

export const handleGetAlerts = async (userId) => {
  const data = await getAlerts(userId);
  return { success: true, data };
};

export const handleMarkAsRead = async (userId, id) => {
  await markAsRead(id, userId);
  return { success: true };
};

export const handleDeleteNotification = async (userId, id) => {
  await deleteNotification(id, userId);
  return { success: true };
};

export const handleGetAdminAlerts = async () => {
  const data = await getAdminAlerts();
  return { success: true, data };
};
