import OpenAI from "openai";
import { sendNotification } from "./notification.repo.js";
import { getDB } from "../config/db.js";

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});


/* =========================
   CHAT
========================= */

export async function handleChat(message, userId, digitalId, hoiThoaiId) {
  const db = getDB();
  let conversationId = hoiThoaiId;
  const now = new Date();

  /* ===== SYSTEM PROMPT ===== */
  const { data: digital } = await db
    .from("digitalhuman")
    .select("systemprompt")
    .eq("digitalhuman_id", digitalId)
    .eq("danghoatdong", true)
    .single();

  if (!digital) throw new Error("Digital Human không tồn tại");

  const systemPrompt = digital.systemprompt;

  /* ===== TẠO HỘI THOẠI ===== */
  if (!conversationId) {
    const newConversationId = "HT" + Date.now().toString().slice(-10);
    const { data: newConv, error } = await db
      .from("hoithoai")
      .insert({
        hoithoai_id: newConversationId,
        thoigiantao: now.toISOString().split("T")[0],
        nguoidung_id: userId,
        digitalhuman_id: digitalId,
        lancuoituongtac: now.toISOString(),
        daxoa: false,
      })
      .select()
      .single();

    if (error) throw error;
    conversationId = newConv.hoithoai_id;
  }

  /* ===== LƯU USER MESSAGE ===== */
  const { data: userMsg, error: errMsg } = await db
    .from("tinnhan")
    .insert({
      tinnhan_id: "TN" + Date.now().toString().slice(-11),
      hoithoai_id: conversationId,
      noidung: message,
      ladigital: false,
      thoigiangui: new Date().toISOString(),
    })
    .select()
    .single();

  if (errMsg) throw errMsg;

  /* ===== DETECT ===== */
  const normalized = message
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/\s+/g, " ");

  const { data: keywords, error: keywordErr } = await db
    .from("tukhoabatthuong")
    .select("tukhoa_id, tukhoa, pattern, mucdotinnhan_id");
  if (keywordErr) throw keywordErr;

  let matched = [];

  for (let k of keywords || []) {
    if (k.pattern) {
      try {
        const regex = new RegExp(k.pattern, "i");
        if (regex.test(normalized)) matched.push(k);
      } catch (_) {
      }
    } else {
      if (!k.tukhoa) continue;
      const kw = k.tukhoa
        .toLowerCase()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "");

      if (normalized.includes(kw)) matched.push(k);
    }
  }

  let mucDoMax = 0;

  if (matched.length > 0) {
    const uniqueMatched = Array.from(
      new Map((matched || []).map(k => [k.tukhoa_id, k])).values()
    );

    for (let k of uniqueMatched) {
      if (!k?.tukhoa_id) continue;
      await db.from("tinnhan_tukhoa").upsert(
        {
          tinnhan_id: userMsg.tinnhan_id,
          tukhoabatthuong_id: k.tukhoa_id,
        },
        { onConflict: "tinnhan_id,tukhoabatthuong_id" }
      );
    }

    const levelIds = uniqueMatched
      .map(i => i.mucdotinnhan_id)
      .filter(Boolean);

    if (levelIds.length > 0) {
      const { data: levels, error: levelErr } = await db
        .from("mucdotinnhan")
        .select("mucdotinnhan_id, mucdo")
        .in("mucdotinnhan_id", levelIds);
      if (levelErr) throw levelErr;

      const parsedLevels = (levels || []).map(i => {
        const raw = i?.mucdo;
        const num = typeof raw === "number" ? raw : Number(raw);
        return Number.isFinite(num) ? num : 0;
      });
      mucDoMax = Math.max(...parsedLevels, 0);
    }
  }

  /* ===== ALERT ===== */
  if (mucDoMax >= 1) {
    const shortMsg =
      message.length > 50 ? message.substring(0, 50) + "..." : message;

    const notiBody = shortMsg;

    await db.from("canhbaotinnhan").insert({
      canhbaotinnhan_id: Date.now().toString().slice(-12),
      motacanhbao: notiBody,
      thoigiancanhbao: new Date().toISOString(),
      daxoa: false,
      tinnhan_id: userMsg.tinnhan_id,
    });

    await sendNotification(userId, "Cảnh báo", notiBody, mucDoMax);
  }

  /* ===== LẤY HISTORY ===== */
  const { data: history } = await db
    .from("tinnhan")
    .select("noidung, ladigital")
    .eq("hoithoai_id", conversationId)
    .order("thoigiangui", { ascending: false })
    .limit(20);

  const messages = [{ role: "system", content: systemPrompt }];

  (history || []).reverse().forEach(row => {
    messages.push({
      role: row.ladigital ? "assistant" : "user",
      content: row.noidung,
    });
  });

  /* ===== OPENAI ===== */
  const completion = await client.chat.completions.create({
    model: "gpt-4o-mini",
    messages,
    temperature: 0.7,
  });

  const aiReply = completion.choices[0].message.content;

  /* ===== SAVE AI ===== */
  await db.from("tinnhan").insert({
    tinnhan_id: "TN" + (Date.now() + 1).toString().slice(-11),
    hoithoai_id: conversationId,
    noidung: aiReply,
    ladigital: true,
    thoigiangui: new Date().toISOString(),
  });

  /* ===== UPDATE LAST CHAT ===== */
  await db
    .from("hoithoai")
    .update({ lancuoituongtac: new Date().toISOString() })
    .eq("hoithoai_id", conversationId);

  return {
    success: true,
    reply: aiReply,
    hoiThoaiId: conversationId,
    mucDo: mucDoMax,
    canhBao: mucDoMax >= 3,
  };
}

/* =========================
   HISTORY
========================= */
export async function getChatHistory(userId) {
  const db = getDB();

  const { data, error } = await db
    .from("hoithoai")
    .select(`
      hoithoai_id,
      lancuoituongtac,
      digitalhuman(
        digitalhuman_id,
        tendigitalhuman,
        imageurl,
        nghenghiep(
          tennghenghiep
        )
      )
    `)
    .eq("nguoidung_id", userId)
    .eq("daxoa", false)
    .order("lancuoituongtac", { ascending: false });

  if (error) throw error;

  return data;
}

/* =========================
   GET MESSAGES
========================= */

export async function getMessages(hoiThoaiId) {
  const db = getDB();

  const { data, error } = await db
    .from("tinnhan")
    .select("noidung, ladigital, thoigiangui")
    .eq("hoithoai_id", hoiThoaiId)
    .order("thoigiangui", { ascending: true });

  if (error) throw error;

  return data;
}
/* =========================
   GET CONVERSATIONS (DASHBOARD)
========================= */
export async function getConversationsStats() {
  const db = getDB();

  const { data, error } = await db
    .from("hoithoai")
    .select("lancuoituongtac")
    .eq("daxoa", false);

  if (error) throw error;

  // group tại JS
  const map = {};

  data.forEach(item => {
    if (!item.lancuoituongtac) return;

    const date = new Date(item.lancuoituongtac)
      .toISOString()
      .split("T")[0];

    map[date] = (map[date] || 0) + 1;
  });

  return Object.entries(map)
    .map(([date, total]) => ({ date, total }))
    .sort((a, b) => new Date(a.date) - new Date(b.date));
}
/* =========================
   DELETE CONVERSATION
========================= */

export async function deleteConversation(hoiThoaiId) {
  const db = getDB();

  const { error } = await db
    .from("hoithoai")
    .update({ daxoa: true })
    .eq("hoithoai_id", hoiThoaiId);

  if (error) throw error;

  return true;
}