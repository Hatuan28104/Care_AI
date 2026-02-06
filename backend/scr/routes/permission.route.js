import express from "express";
import {
  getAllPermissions,
  getPermissionConfigs,
  savePermissionConfig
} from "../repos/permission.repo.js";

const router = express.Router();

/* =========================
   DANH SÁCH QUYỀN (MASTER)
========================= */
router.get("/", async (req, res) => {
  try {
    const data = await getAllPermissions();
    res.json({ success: true, data });
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

/* =========================
   QUYỀN THEO QUAN HỆ
========================= */
router.get("/:quanHeId", async (req, res) => {
  try {
    const data = await getPermissionConfigs(req.params.quanHeId);
    res.json({ success: true, data });
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

/* =========================
   BẬT / TẮT QUYỀN
========================= */
router.post("/", async (req, res) => {
  try {
    const { quanHeId, quyenId, active } = req.body;

    if (!quanHeId || !quyenId) {
      throw new Error("Thiếu dữ liệu cấu hình");
    }

    await savePermissionConfig(quanHeId, quyenId, active);

    res.json({ success: true });
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

export default router;
