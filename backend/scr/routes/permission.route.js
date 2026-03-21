import express from "express";
import {
  getAllPermissions,
  getPermissionConfigs,
  savePermissionConfig,
  getSharedConversation
} from "../repos/permission.repo.js";
import { auth } from "../middlewares/auth.middleware.js";
import { getDB } from "../config/db.js";

const router = express.Router();

/* =========================
   DANH SÁCH QUYỀN (MASTER)
========================= */
router.get("/", auth, async (req, res) => {
  try {
    const data = await getAllPermissions();

    res.json({ success: true, data });
  } catch (e) {
    console.error("GET permissions error:", e);

    res.status(500).json({
      success: false,
      message: "Không lấy được danh sách quyền"
    });
  }
});

/* =========================
   CHECK USER CÓ QUYỀN TRONG QH
========================= */
async function checkAccess(userId, quanHeId) {
  const db = getDB();

  const { data } = await db
    .from("quanhegiamho")
    .select("quanhegiamho_id")
    .eq("quanhegiamho_id", quanHeId)
    .or(`nguoigiamho_id.eq.${userId},nguoiduocgiamho_id.eq.${userId}`)
    .eq("daxoa", false)
    .maybeSingle();

  return !!data;
}

/* =========================
   QUYỀN THEO QUAN HỆ
========================= */
router.get("/config/:quanHeId", auth, async (req, res) => {
  try {
    const { quanHeId } = req.params;
    const userId = req.user.nguoidung_id;

    if (!quanHeId) {
      return res.status(400).json({
        success: false,
        message: "Thiếu QuanHeGiamHo_ID"
      });
    }

    // 🔥 check quyền
    if (!(await checkAccess(userId, quanHeId))) {
      return res.status(403).json({ success: false });
    }

    const data = await getPermissionConfigs(quanHeId);

    res.json({ success: true, data });

  } catch (e) {
    console.error("GET permission config error:", e);

    res.status(500).json({
      success: false,
      message: "Không lấy được cấu hình quyền"
    });
  }
});

/* =========================
   BẬT / TẮT QUYỀN
========================= */
router.post("/save", auth, async (req, res) => {
  try {
    const { quanHeId, quyenId, active } = req.body;
    const userId = req.user.nguoidung_id;

    if (!quanHeId || !quyenId) {
      return res.status(400).json({
        success: false,
        message: "Thiếu dữ liệu cấu hình"
      });
    }

    // 🔥 check quyền
    if (!(await checkAccess(userId, quanHeId))) {
      return res.status(403).json({ success: false });
    }

    await savePermissionConfig(quanHeId, quyenId, active);

    res.json({
      success: true,
      message: "Cập nhật quyền thành công"
    });

  } catch (e) {
    console.error("SAVE permission error:", e);

    res.status(500).json({
      success: false,
      message: "Không lưu được cấu hình quyền"
    });
  }
});

/* =========================
   LẤY CONVERSATION ĐƯỢC SHARE
========================= */
router.get("/shared/:quanHeId", auth, async (req, res) => {
  try {
    const { quanHeId } = req.params;
    const userId = req.user.nguoidung_id;

    // 🔥 check quyền
    if (!(await checkAccess(userId, quanHeId))) {
      return res.status(403).json({ success: false });
    }

    const data = await getSharedConversation(quanHeId);

    res.json({
      success: true,
      data
    });

  } catch (e) {
    console.error("GET shared conversation error:", e);

    res.status(500).json({
      success: false,
      message: "Không lấy được hội thoại chia sẻ"
    });
  }
});

export default router;