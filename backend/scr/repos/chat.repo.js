import dotenv from "dotenv";
dotenv.config();
import OpenAI from "openai";
import sql from "mssql";
import { getDB } from "../config/db.js";

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

/* =========================
   CHAT
========================= */

export async function handleChat(message, userId, digitalId, hoiThoaiId) {
  const pool = await getDB();
  let conversationId = hoiThoaiId;

  /* =========================
     1️⃣ SYSTEM PROMPT
  ========================= */

  const digitalResult = await pool
    .request()
    .input("DigitalHuman_ID", sql.Char(12), digitalId).query(`
      SELECT SystemPrompt
      FROM DigitalHuman
      WHERE RTRIM(DigitalHuman_ID)=RTRIM(@DigitalHuman_ID)
      AND DangHoatDong = 1
    `);

  if (digitalResult.recordset.length === 0) {
    throw new Error("Digital Human không tồn tại");
  }

  const systemPrompt = digitalResult.recordset[0].SystemPrompt;

  /* =========================
     2️⃣ TẠO / LẤY HỘI THOẠI
  ========================= */

  if (!conversationId) {
    const createConversation = await pool
      .request()
      .input("NguoiDung_ID", sql.Char(12), userId)
      .input("DigitalHuman_ID", sql.Char(12), digitalId)
      .output("HoiThoai_ID", sql.Char(12))
      .output("ret", sql.Bit)
      .execute("sp_TaoHoiThoai");

    if (!createConversation.output.ret) {
      throw new Error("Không tạo được hội thoại");
    }

    conversationId = createConversation.output.HoiThoai_ID;
  }

  /* =========================
     3️⃣ LƯU TIN NHẮN USER
  ========================= */

  const saveUser = await pool
    .request()
    .input("HoiThoai_ID", sql.Char(12), conversationId)
    .input("NoiDung", sql.NVarChar(sql.MAX), message)
    .input("LaDigital", sql.Bit, 0)
    .output("ret", sql.Bit)
    .execute("sp_LuuTinNhan");

  if (!saveUser.output.ret) {
    throw new Error("Lưu tin nhắn user thất bại");
  }

  /* =========================
     4️⃣ LẤY CONTEXT CHAT
  ========================= */

  const history = await pool
    .request()
    .input("HoiThoai_ID", sql.Char(12), conversationId).query(`
      SELECT TOP 20
        NoiDung,
        LaDigital
      FROM TinNhan
      WHERE HoiThoai_ID = @HoiThoai_ID
      ORDER BY ThoiGianGui DESC
    `);

  const messages = [{ role: "system", content: systemPrompt }];

  history.recordset.reverse().forEach((row) => {
    messages.push({
      role: row.LaDigital ? "assistant" : "user",
      content: row.NoiDung,
    });
  });

  /* =========================
     5️⃣ OPENAI
  ========================= */

  const completion = await client.chat.completions.create({
    model: "gpt-4o-mini",
    messages: messages,
    temperature: 0.7,
  });

  const aiReply = completion.choices[0].message.content;

  /* =========================
     6️⃣ LƯU TIN AI
  ========================= */

  const saveAI = await pool
    .request()
    .input("HoiThoai_ID", sql.Char(12), conversationId)
    .input("NoiDung", sql.NVarChar(sql.MAX), aiReply)
    .input("LaDigital", sql.Bit, 1)
    .output("ret", sql.Bit)
    .execute("sp_LuuTinNhan");

  if (!saveAI.output.ret) {
    throw new Error("Lưu tin nhắn AI thất bại");
  }

  return {
    success: true,
    reply: aiReply,
    hoiThoaiId: conversationId,
  };
}

/* =========================
   HISTORY
========================= */

export async function getChatHistory(userId) {
  const pool = await getDB();

  const result = await pool
    .request()
    .input("NguoiDung_ID", sql.Char(12), userId).query(`
      SELECT
        h.HoiThoai_ID,
        h.LanCuoiTuongTac,
        ISNULL(h.Title, d.TenDigitalHuman) AS TenDigitalHuman,
        d.ImageUrl,
        d.DigitalHuman_ID,
        n.TenNgheNghiep AS NgheNghiep
      FROM HoiThoai h
      JOIN DigitalHuman d
        ON h.DigitalHuman_ID = d.DigitalHuman_ID
      JOIN NgheNghiep n
        ON d.NgheNghiep_ID = n.NgheNghiep_ID
      WHERE h.NguoiDung_ID = @NguoiDung_ID
      AND h.DaXoa = 0
      ORDER BY h.LanCuoiTuongTac DESC
    `);

  return result.recordset;
}

/* =========================
   GET MESSAGES
========================= */

export async function getMessages(hoiThoaiId) {
  const pool = await getDB();

  const result = await pool
    .request()
    .input("HoiThoai_ID", sql.Char(12), hoiThoaiId).query(`
      SELECT
        NoiDung,
        LaDigital,
        ThoiGianGui
      FROM TinNhan
      WHERE HoiThoai_ID = @HoiThoai_ID
      ORDER BY ThoiGianGui ASC
    `);

  return result.recordset;
}

/* =========================
   DELETE CONVERSATION
========================= */

export async function deleteConversation(hoiThoaiId) {
  const pool = await getDB();

  await pool.request().input("HoiThoai_ID", sql.Char(12), hoiThoaiId).query(`
      UPDATE HoiThoai
      SET DaXoa = 1
      WHERE HoiThoai_ID = @HoiThoai_ID
    `);

  return true;
}

/* =========================
   RENAME CONVERSATION
========================= */

export async function renameConversation(hoiThoaiId, title) {
  const pool = await getDB();

  await pool
    .request()
    .input("HoiThoai_ID", sql.Char(12), hoiThoaiId)
    .input("Title", sql.NVarChar(255), title).query(`
      UPDATE HoiThoai
      SET Title = @Title
      WHERE HoiThoai_ID = @HoiThoai_ID
    `);

  return true;
}
