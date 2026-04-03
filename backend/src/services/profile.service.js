import { updateProfile, getProfileById, getAllUsers, deleteUser, getUserStats } from "../repos/profile.repo.js";

export const handleGetAllUsers = async () => {
  const users = await getAllUsers();
  return { success: true, data: users };
};

export const handleGetUserStats = async () => {
  const data = await getUserStats();
  return { success: true, data };
};

export const handleGetProfileById = async (id) => {
  const profile = await getProfileById(id);
  if (!profile) {
    throw new Error("Chưa có hồ sơ");
  }
  return { success: true, data: profile };
};

export const handleUpdateProfile = async (id, file, body) => {
  const avatarUrl = file ? `/uploads/avatars/${file.filename}` : undefined;
  try {
    const updated = await updateProfile({
      ...body,
      nguoiDungId: id,
      avatarUrl,
    });
    return { success: true, data: updated };
  } catch (e) {
    const err = new Error(e.message);
    err.errors = e.errors || null;
    throw err;
  }
};

export const handleDeleteUser = async (id) => {
  await deleteUser(id);
  return { success: true };
};
