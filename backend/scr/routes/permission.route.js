import express from "express";
import {
  getAllPermissions,
  getPermissionConfigs,
  savePermissionConfig,
  getSharedConversation
} from "../repos/permission.repo.js";

const router = express.Router();

/* =========================
   DANH SÁCH QUYỀN (MASTER)
========================= */
router.get("/", async (req, res) => {
  try {

    const data = await getAllPermissions();

    res.json({
      success: true,
      data
    });

  } catch (e) {

    console.error("GET permissions error:", e);

    res.status(500).json({
      success: false,
      message: "Không lấy được danh sách quyền"
    });

  }
});

/* =========================
   QUYỀN THEO QUAN HỆ
========================= */
router.get("/config/:quanHeId", async (req, res) => {
  try {

    const { quanHeId } = req.params;

    if (!quanHeId) {
      return res.status(400).json({
        success: false,
        message: "Thiếu QuanHeGiamHo_ID"
      });
    }

    const data = await getPermissionConfigs(quanHeId);

    res.json({
      success: true,
      data
    });

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
router.post("/save", async (req, res) => {
  try {

    const { quanHeId, quyenId, active } = req.body;

    if (!quanHeId || !quyenId) {
      return res.status(400).json({
        success: false,
        message: "Thiếu dữ liệu cấu hình"
      });
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
router.get("/getSharedConversation/:quanHeId", async (req, res) => {
  try {

    const { quanHeId } = req.params;

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