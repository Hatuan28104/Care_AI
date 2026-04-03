import { sendInviteByPhone, acceptInvite, rejectInvite, getInvites, findUserByPhone, cancelInvite } from "../repos/invite.repo.js";

export const handleSendInviteByPhone = async (fromUserId, phone) => {
  if (!phone) throw new Error("Thiếu số điện thoại");
  await sendInviteByPhone(fromUserId, phone);
  return { success: true, message: "Đã gửi lời mời" };
};

export const handleFindByPhone = async (currentUserId, phone) => {
  if (!phone) throw new Error("Thiếu số điện thoại");
  const users = await findUserByPhone(phone, currentUserId);
  return { success: true, data: users };
};

export const handleAcceptInvite = async (loiMoiId) => {
  if (!loiMoiId) throw new Error("Thiếu ID lời mời");
  const newDep = await acceptInvite(loiMoiId);
  return { success: true, data: newDep };
};

export const handleRejectInvite = async (loiMoiId) => {
  if (!loiMoiId) throw new Error("Thiếu ID lời mời");
  await rejectInvite(loiMoiId);
  return { success: true, message: "Đã từ chối lời mời" };
};

export const handleGetIncoming = async (userId) => {
  const data = await getInvites(userId);
  return { success: true, data };
};

export const handleCancel = async (fromId, loiMoiId) => {
  if (!loiMoiId) throw new Error("Thiếu ID lời mời");
  await cancelInvite(loiMoiId, fromId);
  return { success: true };
};
