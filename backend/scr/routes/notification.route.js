import express from "express";
import sql from "mssql";
import { getDB } from "../config/db.js";
import {
  sendNotification,
  sendToAll,
  markAsRead,
  deleteNotification,
} from "../repos/notification.repo.js";

const router = express.Router();

/* ===== TEST ===== */
router.post("/test", async (req, res) => {
  const { userId } = req.body;

  await sendNotification(
    userId,
    "Test tự động 🔥",
    "Backend tự gửi nè!"
  );

  res.json({ success: true });
});

/* ===== BROADCAST ===== */
router.post("/broadcast", async (req, res) => {
  await sendToAll(
    "Broadcast 🔥",
    "Test gửi cho tất cả user"
  );

  res.json({ success: true });
});

/* =========================
   GET ALERTS (FIX ROUTE)
========================= */
router.get("/user/:userId", async (req, res) => {
  try {
    const pool = await getDB();

    const result = await pool.request()
      .input("userId", sql.Char(12), req.params.userId)
      .query(`
        SELECT 
          Notification_ID,
          TieuDe,
          NoiDung,
          ThoiGian,
          DaDoc
        FROM Notifications
        WHERE RTRIM(NguoiDung_ID) = RTRIM(@userId)
        ORDER BY ThoiGian DESC
      `);

    res.json(result.recordset); // 🔥 trả thẳng cho Flutter dễ dùng

  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
});

/* =========================
   MARK AS READ
========================= */
router.post("/read/:id", async (req, res) => {
  const { id } = req.params;
  const { userId } = req.body;

  await markAsRead(id, userId);

  res.json({ success: true });
});

/* =========================
   DELETE
========================= */
router.delete("/:id", async (req, res) => {
  const { id } = req.params;
  const { userId } = req.body;

  await deleteNotification(id, userId);

  res.json({ success: true });
});
/* =========================
   GET REAL ALERTS (CHUẨN)
========================= */
router.get("/alerts", async (req, res) => {
  try {
    const db = await getDB();

    const result = await db.request().query(`
      SELECT 
        CanhBaoTinNhan_ID,
        MoTaCanhBao,
        ThoiGianCanhBao AS CreatedAt
      FROM CanhBaoTinNhan
      WHERE DaXoa = 0
      ORDER BY ThoiGianCanhBao DESC
    `);

    res.json({
      success: true,
      data: result.recordset
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});
export default router;