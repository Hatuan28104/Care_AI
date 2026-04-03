import { getSettings, updateSetting } from "../repos/settings.repo.js";

export const handleGetSettings = async (userId) => {
  const data = await getSettings(userId);
  return data;
};

export const handleUpdateSetting = async (userId, key, value) => {
  await updateSetting(userId, key, value);
  return { success: true };
};
