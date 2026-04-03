import dotenv from "dotenv";
dotenv.config();

import { getDB } from "../config/db.js";

/* =========================
   DANH SÁCH QUYỀN
========================= */
export async function getAllPermissions() {
  const db = getDB();

  const { data, error } = await db
    .from("loaichisosuckhoe")
    .select("loaichiso_id, tenchiso")
    .order("loaichiso_id", { ascending: true });

  if (error) throw error;

  return (data || []).map(i => ({
    quyen_id: i.loaichiso_id,
    tenquyen: i.tenchiso,
  }));
}

/* =========================
   QUYỀN ĐÃ CẤU HÌNH THEO QUAN HỆ
========================= */
export async function getPermissionConfigs(quanHeId) {
  const db = getDB();

  const { data, error } = await db
    .from("cauhinhdulieu")
    .select("quyen, dakichhoat")
    .eq("quanhegiamho_id", quanHeId);

  if (error) throw error;

  return data.map(i => ({
    quyen_id: i.quyen,
    dakichhoat: i.dakichhoat ? 1 : 0,
  }));
}

/* =========================
   BẬT / TẮT QUYỀN
========================= */
export async function savePermissionConfig(quanHeId, quyenId, active) {
  const db = getDB();

  const { data: existing, error: checkErr } = await db
    .from("cauhinhdulieu")
    .select("cauhinhdulieu_id")
    .eq("quanhegiamho_id", quanHeId)
    .eq("quyen", quyenId)
    .maybeSingle();

  if (checkErr) throw checkErr;

  if (existing) {
    const { error } = await db
      .from("cauhinhdulieu")
      .update({
        dakichhoat: active,
        thoigianch: new Date().toISOString(),
      })
      .eq("cauhinhdulieu_id", existing.cauhinhdulieu_id);
    if (error) throw error;
    return;
  }

  const { error } = await db.from("cauhinhdulieu").insert({
    cauhinhdulieu_id: "CHDL" + Date.now().toString().slice(-8),
    quanhegiamho_id: quanHeId,
    quyen: quyenId,
    dakichhoat: active,
    thoigianch: new Date().toISOString(),
  });
  if (error) throw error;
}
/* =========================
   LẤY CONVERSATION ĐƯỢC SHARE
========================= */
export async function getSharedConversation(quanHeId) {
  const db = getDB();

  const { data: configs, error } = await db
    .from("cauhinhdulieu")
    .select("quyen")
    .eq("quanhegiamho_id", quanHeId)
    .eq("dakichhoat", true)
    .like("quyen", "HT%");

  if (error) throw error;
  const hoiThoaiIds = (configs || []).map(i => i.quyen).filter(Boolean);
  if (hoiThoaiIds.length === 0) return [];

  const { data: conversations, error: convErr } = await db
    .from("hoithoai")
    .select(`
      hoithoai_id,
      lancuoituongtac,
      digitalhuman (
        tendigitalhuman,
        imageurl
      )
    `)
    .in("hoithoai_id", hoiThoaiIds)
    .eq("daxoa", false)
    .order("lancuoituongtac", { ascending: false });

  if (convErr) throw convErr;

  const convList = conversations || [];
  if (convList.length === 0) return [];

  const convIds = convList.map(i => i.hoithoai_id);
  const { data: messages, error: msgErr } = await db
    .from("tinnhan")
    .select("hoithoai_id, noidung, thoigiangui")
    .in("hoithoai_id", convIds)
    .order("thoigiangui", { ascending: false });
  if (msgErr) throw msgErr;

  const latestMessageByConversation = {};
  for (const m of messages || []) {
    if (!latestMessageByConversation[m.hoithoai_id]) {
      latestMessageByConversation[m.hoithoai_id] = {
        noidung: m.noidung,
        thoigiangui: m.thoigiangui,
      };
    }
  }

  return convList.map(i => ({
    hoithoai_id: i.hoithoai_id,
    tendigitalhuman: i.digitalhuman?.tendigitalhuman || "",
    imageurl: i.digitalhuman?.imageurl || "",
    lancuoituongtac: i.lancuoituongtac,
    last_message: latestMessageByConversation[i.hoithoai_id]?.noidung || "",
    last_message_time:
      latestMessageByConversation[i.hoithoai_id]?.thoigiangui || null,
  }));
}
/* =========================
   CHECK ACCESS
========================= */
export async function checkPermissionAccess(userId, quanHeId) {
  const db = getDB();

  const { data, error } = await db
    .from("quanhegiamho")
    .select("quanhegiamho_id")
    .eq("quanhegiamho_id", quanHeId)
    .or(`nguoigiamho_id.eq.${userId},nguoiduocgiamho_id.eq.${userId}`)
    .eq("daxoa", false)
    .maybeSingle();

  if (error) throw error;

  return !!data;
}
/* =========================
   LẤY QUYỀN HEALTH ĐƯỢC SHARE
========================= */
export async function getAllowedHealthPermissions(quanHeId) {
  const db = getDB();

  const { data, error } = await db
    .from("cauhinhdulieu")
    .select("quyen")
    .eq("quanhegiamho_id", quanHeId)
    .eq("dakichhoat", true)
    .like("quyen", "CS%"); 

  if (error) throw error;

  return (data || []).map(i => i.quyen);
}