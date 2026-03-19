import OpenAI from "openai";
import sql from "mssql";
import { sendNotification } from "./notification.repo.js";
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

  /* ===== SYSTEM PROMPT ===== */

  const digital = await pool
    .request()
    .input("DigitalHuman_ID", sql.Char(12), digitalId).query(`
      SELECT SystemPrompt
      FROM DigitalHuman
      WHERE RTRIM(DigitalHuman_ID) = RTRIM(@DigitalHuman_ID)
      AND DangHoatDong = 1
    `);

  if (digital.recordset.length === 0) {
    throw new Error("Digital Human không tồn tại");
  }

  const systemPrompt = digital.recordset[0].SystemPrompt;

  /* ===== TẠO HỘI THOẠI ===== */

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
     LƯU TIN NHẮN USER
  ========================= */

  const saveUser = await pool.request()
    .input("HoiThoai_ID", sql.Char(12), conversationId)
    .input("NoiDung", sql.NVarChar(sql.MAX), message)
    .input("LaDigital", sql.Bit, 0)
    .output("TinNhan_ID", sql.Char(12))
    .output("ret", sql.Bit)
    .query(`
      EXEC sp_LuuTinNhan 
        @HoiThoai_ID,
        @NoiDung,
        @LaDigital,
        @TinNhan_ID OUTPUT,
        @ret OUTPUT
    `);

  if (!saveUser.output.ret) {
    throw new Error("Lưu tin nhắn user thất bại");
  }
  // ================= DETECT BẤT THƯỜNG =================

  // 🔹 normalize text
  const normalized = message
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "") // bỏ dấu
    .replace(/\s+/g, " ");

  // 🔹 lấy danh sách keyword
  const keywordResult = await pool.request().query(`
    SELECT * FROM TuKhoaBatThuong
  `);

  const keywords = keywordResult.recordset;

  let matchedKeywords = [];

  // 🔹 detect
  for (let k of keywords) {
    if (k.Pattern) {
      const regex = new RegExp(k.Pattern);
      if (regex.test(normalized)) {
        matchedKeywords.push(k);
      }
    } else {
      const keywordNormalized = k.TuKhoa
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "");

    if (normalized.includes(keywordNormalized)) {
        matchedKeywords.push(k);
      }
    }
  }

  // 🔹 nếu có match → lưu mapping
  let mucDoMax = 0;

  for (let k of matchedKeywords) {
    await pool.request()
      .input("TinNhan_ID", sql.Char(12), saveUser.output.TinNhan_ID)
      .input("TuKhoaBatThuong_ID", sql.Char(12), k.TuKhoaBatThuong_ID)
      .query(`
        INSERT INTO TinNhan_TuKhoa (TinNhan_ID, TuKhoaBatThuong_ID)
        VALUES (@TinNhan_ID, @TuKhoaBatThuong_ID)
      `);
  }

  // 🔹 lấy mức độ cao nhất
  if (matchedKeywords.length > 0) {
    const mucDoResult = await pool.request()
      .input("TinNhan_ID", sql.Char(12), saveUser.output.TinNhan_ID)
      .query(`
        SELECT MAX(md.MucDo) AS mucDo
        FROM TinNhan_TuKhoa tntk
        JOIN TuKhoaBatThuong tk ON tntk.TuKhoaBatThuong_ID = tk.TuKhoaBatThuong_ID
        JOIN MucDoTinNhan md ON tk.MucDoTinNhan_ID = md.MucDoTinNhan_ID
        WHERE tntk.TinNhan_ID = @TinNhan_ID
      `);

    mucDoMax = mucDoResult.recordset[0].mucDo || 0;
  }


  // 🔹 nếu nguy hiểm → tạo cảnh báo
  if (mucDoMax >= 1) {

    let notiTitle = "Tâm trạng không ổn";

    if (mucDoMax === 2) {
      notiTitle = "Bạn đang gặp áp lực";
    }

    if (mucDoMax >= 3) {
      notiTitle = "Cảnh báo nguy hiểm";
    }
    // ===== LẤY TÊN USER =====
    const userInfo = await pool.request()
      .input("userId", sql.Char(12), userId)
      .query(`
        SELECT TenND
        FROM NguoiDung
        WHERE NguoiDung_ID = @userId
      `);

    const userName = userInfo.recordset[0]?.TenND || userId;

    // ===== RÚT GỌN MESSAGE =====
    const shortMsg = message.length > 50
      ? message.substring(0, 50) + "..."
      : message;

    // ===== BODY NOTIFICATION =====
    const notiBody = `${userName}: "${shortMsg}"`;

    // ===== LƯU CẢNH BÁO =====
    await pool.request()
      .input("CanhBaoTinNhan_ID", sql.Char(12), Date.now().toString().slice(-12))
      .input("MoTaCanhBao", sql.NVarChar(255), notiBody)
      .input("ThoiGianCanhBao", sql.DateTime2, new Date())
      .input("DaXoa", sql.Bit, 0)
      .input("TinNhan_ID", sql.Char(12), saveUser.output.TinNhan_ID)
      .query(`
        INSERT INTO CanhBaoTinNhan
        (CanhBaoTinNhan_ID, MoTaCanhBao, ThoiGianCanhBao, DaXoa, TinNhan_ID)
        VALUES (@CanhBaoTinNhan_ID, @MoTaCanhBao, @ThoiGianCanhBao, @DaXoa, @TinNhan_ID)
      `);

    // ===== GỬI NOTIFICATION =====
    try {
      let title = "Tâm trạng không ổn";

      if (mucDoMax === 2) {
        title = "Bạn đang gặp áp lực";
      }

      if (mucDoMax >= 3) {
        title = "Cảnh báo nguy hiểm";
      }

      await sendNotification(userId, title, notiBody, mucDoMax);

    } catch (err) {
    }
  }
  /* =========================
     LẤY CONTEXT CHAT
  ========================= */

  const history = await pool
    .request()
    .input("HoiThoai_ID", sql.Char(12), conversationId).query(`
      SELECT TOP 20
        NoiDung,
        LaDigital
      FROM TinNhan
      WHERE RTRIM(HoiThoai_ID) = RTRIM(@HoiThoai_ID)
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
     OPENAI
  ========================= */

  const completion = await client.chat.completions.create({
    model: "gpt-4o-mini",
    messages: messages,
    temperature: 0.7,
  });

  const aiReply = completion.choices[0].message.content;

  /* =========================
     LƯU TIN AI
  ========================= */

  const saveAI = await pool.request()
    .input("HoiThoai_ID", sql.Char(12), conversationId)
    .input("NoiDung", sql.NVarChar(sql.MAX), aiReply)
    .input("LaDigital", sql.Bit, 1)
    .output("ret", sql.Bit)
    .query(`
      EXEC sp_LuuTinNhan 
        @HoiThoai_ID,
        @NoiDung,
        @LaDigital,
        NULL,
        @ret OUTPUT
    `);

  if (!saveAI.output.ret) {
    throw new Error("Lưu tin nhắn AI thất bại");
  }

  /* =========================
     UPDATE LAST CHAT
  ========================= */

  await pool.request().input("HoiThoai_ID", sql.Char(12), conversationId)
    .query(`
      UPDATE HoiThoai
      SET LanCuoiTuongTac = GETDATE()
      WHERE RTRIM(HoiThoai_ID) = RTRIM(@HoiThoai_ID)
    `);

  return {
    success: true,
    reply: aiReply,
    hoiThoaiId: conversationId,
    mucDo: mucDoMax,
    canhBao: mucDoMax >= 3
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
        d.TenDigitalHuman,
        d.ImageUrl,
        d.DigitalHuman_ID,
        n.TenNgheNghiep AS NgheNghiep
      FROM HoiThoai h
      JOIN DigitalHuman d
        ON h.DigitalHuman_ID = d.DigitalHuman_ID
      JOIN NgheNghiep n
        ON d.NgheNghiep_ID = n.NgheNghiep_ID
      WHERE RTRIM(h.NguoiDung_ID) = RTRIM(@NguoiDung_ID) AND h.DaXoa = 0
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
    .input("HoiThoai_ID", sql.VarChar(12), hoiThoaiId)
    .query(`
      SELECT
        NoiDung,
        LaDigital,
        ThoiGianGui
      FROM TinNhan
      WHERE RTRIM(HoiThoai_ID) = RTRIM(@HoiThoai_ID)
      ORDER BY ThoiGianGui ASC
    `);

  return result.recordset;
}
/* =========================
   GET CONVERSATIONS (DASHBOARD)
========================= */
export async function getConversationsStats() {
  const pool = await getDB();

  const result = await pool.request().query(`
    SELECT 
      CONVERT(VARCHAR(10), LanCuoiTuongTac, 23) AS date, 
      COUNT(*) AS total
    FROM HoiThoai
    WHERE DaXoa = 0
    GROUP BY CONVERT(VARCHAR(10), LanCuoiTuongTac, 23)
    ORDER BY date
  `);

  return result.recordset || [];
}
/* =========================
   DELETE CONVERSATION
========================= */

export async function deleteConversation(hoiThoaiId) {
  const pool = await getDB();

  await pool.request().input("HoiThoai_ID", sql.Char(12), hoiThoaiId).query(`
      UPDATE HoiThoai
      SET DaXoa = 1
      WHERE RTRIM(HoiThoai_ID) = RTRIM(@HoiThoai_ID)
    `);

  return true;
}
