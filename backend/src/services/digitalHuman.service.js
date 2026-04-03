import { getAllDigitalHuman, getDigitalHumanById, createDigitalHuman, updateDigitalHuman, deleteDigitalHuman } from "../repos/digitalHuman.repo.js";

export const handleGetAll = async () => {
  const data = await getAllDigitalHuman();
  return { success: true, data };
};

export const handleGetById = async (id) => {
  const data = await getDigitalHumanById(id);
  return { success: true, data };
};

export const handleCreate = async (file, body) => {
  const image = file ? `uploads/avatars/${file.filename}` : "";
  const data = { ...body, image };
  const result = await createDigitalHuman(data);
  return { success: true, message: result.message };
};

export const handleUpdate = async (id, file, body) => {
  let image = body.image;
  if (file) {
    image = `uploads/avatars/${file.filename}`;
  }
  const data = { ...body, image };
  const result = await updateDigitalHuman(id, data);
  return { success: true, message: result.message };
};

export const handleDelete = async (id) => {
  const result = await deleteDigitalHuman(id);
  return { success: true, message: result.message };
};
