import express from "express";
import * as permissionService from "../services/permission.service.js";
import { auth } from "../middlewares/auth.middleware.js";

const router = express.Router();

router.get("/", auth, async (req, res) => {
  try {
    const response = await permissionService.handleGetAllPermissions();
    res.json(response);
  } catch (e) {
    console.error("GET permissions error:", e);
    res.status(500).json({ success: false, message: "Không lấy được danh sách quyền" });
  }
});

router.get("/config/:quanHeId", auth, async (req, res) => {
  try {
    const response = await permissionService.handleGetPermissionConfigs(req.user.nguoidung_id, req.params.quanHeId);
    res.json(response);
  } catch (e) {
    if (e.status === 403) return res.status(403).json({ success: false });
    if (e.message === "Thiếu QuanHeGiamHo_ID") return res.status(400).json({ success: false, message: e.message });
    console.error("GET permission config error:", e);
    res.status(500).json({ success: false, message: "Không lấy được cấu hình quyền" });
  }
});

router.post("/save", auth, async (req, res) => {
  try {
    const { quanHeId, quyenId, active } = req.body;
    const response = await permissionService.handleSavePermissionConfig(req.user.nguoidung_id, quanHeId, quyenId, active);
    res.json(response);
  } catch (e) {
    if (e.status === 403) return res.status(403).json({ success: false });
    if (e.message === "Thiếu dữ liệu cấu hình") return res.status(400).json({ success: false, message: e.message });
    console.error("SAVE permission error:", e);
    res.status(500).json({ success: false, message: "Không lưu được cấu hình quyền" });
  }
});

router.get("/shared/:quanHeId", auth, async (req, res) => {
  try {
    const response = await permissionService.handleGetSharedConversation(req.user.nguoidung_id, req.params.quanHeId);
    res.json(response);
  } catch (e) {
    if (e.status === 403) return res.status(403).json({ success: false });
    console.error("GET shared conversation error:", e);
    res.status(500).json({ success: false, message: "Không lấy được hội thoại chia sẻ" });
  }
});

router.get("/health/:quanHeId", auth, async (req, res) => {
  try {
    const response = await permissionService.handleGetHealthReport(req.user.nguoidung_id, req.params.quanHeId, req.query.type);
    res.json(response);
  } catch (e) {
    if (e.status === 403) return res.status(403).json({ success: false });
    if (e.message === "Thiếu QuanHeGiamHo_ID") return res.status(400).json({ success: false, message: e.message });
    console.error("GET shared health error:", e);
    res.status(500).json({ success: false, message: "Không lấy được dữ liệu sức khỏe" });
  }
});

export default router;