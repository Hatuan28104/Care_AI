import { getDB } from "../config/db.js";

/* =========================
   GET ALL DIGITAL HUMAN
========================= */
export async function getAllDigitalHuman() {
  const db = getDB();

  const { data, error } = await db
    .from("digitalhuman")
    .select(`
      digitalhuman_id,
      tendigitalhuman,
      imageurl,
      mota,
      gioitinh,
      nghenghiep_id,
      ngoaihinh,
      nghenghiep (tennghenghiep)
    `);

  if (error) throw error;

  return data;
}

/* =========================
   GET DIGITAL HUMAN BY ID
========================= */
export async function getDigitalHumanById(id) {
  const db = getDB();

  const { data, error } = await db
    .from("digitalhuman")
    .select(`
      digitalhuman_id,
      tendigitalhuman,
      imageurl,
      mota,
      gioitinh,
      nghenghiep_id,
      ngoaihinh,
      nghenghiep (tennghenghiep)
    `)
    .eq("digitalhuman_id", id)
    .single();

  if (error) throw error;

  return data;
}

/* =========================
   CREATE DIGITAL HUMAN
========================= */
export async function createDigitalHuman(dataInput) {
  const db = getDB();

  const { error } = await db
    .from("digitalhuman")
    .insert([
      {
        digitalhuman_id: dataInput.id,
        tendigitalhuman: dataInput.name,
        imageurl: dataInput.image,
        mota: dataInput.prompt,
        nghenghiep_id: dataInput.jobId,
        gioitinh: dataInput.gender,
        ngoaihinh: dataInput.appearance,
      },
    ]);

  if (error) throw error;

  return { message: "Tạo Digital Human thành công" };
}

/* =========================
   UPDATE DIGITAL HUMAN
========================= */
export async function updateDigitalHuman(id, dataInput) {
  const db = getDB();

  const { error } = await db
    .from("digitalhuman")
    .update({
      tendigitalhuman: dataInput.name,
      imageurl: dataInput.image,
      mota: dataInput.prompt,
      nghenghiep_id: dataInput.jobId,
      gioitinh: dataInput.gender,
      ngoaihinh: dataInput.appearance,
    })
    .eq("digitalhuman_id", id);

  if (error) throw error;

  return { message: "Cập nhật Digital Human thành công" };
}

/* =========================
   DELETE DIGITAL HUMAN
========================= */
export async function deleteDigitalHuman(id) {
  const db = getDB();

  const { error } = await db
    .from("digitalhuman")
    .delete()
    .eq("digitalhuman_id", id);

  if (error) throw error;

  return { message: "Xóa Digital Human thành công" };
}