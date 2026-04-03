import { getMyGuardians, getMyDependents, endRelationship, getRelationshipProfile } from "../repos/relationship.repo.js";

export const handleGetRelationshipProfile = async (qhId, userId) => {
  const data = await getRelationshipProfile(qhId, userId);
  return { success: true, data };
};

export const handleGetMyGuardians = async (userId) => {
  const data = await getMyGuardians(userId);
  return { success: true, data };
};

export const handleGetMyDependents = async (userId) => {
  const data = await getMyDependents(userId);
  return { success: true, data };
};

export const handleEndRelationship = async (quanHeId) => {
  await endRelationship(quanHeId);
  return { success: true };
};
