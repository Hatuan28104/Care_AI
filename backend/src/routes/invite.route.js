import express from "express";
import * as inviteService from "../services/invite.service.js";
import { auth } from "../middlewares/auth.middleware.js";

const router = express.Router();

router.post("/by-phone", auth, async (req, res) => {
  try {
    const response = await inviteService.handleSendInviteByPhone(req.user.nguoidung_id, req.body.phone);
    res.json(response);
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

router.get("/find-by-phone", auth, async (req, res) => {
  try {
    const response = await inviteService.handleFindByPhone(req.user.nguoidung_id, req.query.phone);
    res.json(response);
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

router.post("/accept", auth, async (req, res) => {
  try {
    const response = await inviteService.handleAcceptInvite(req.body.loiMoiId);
    res.json(response);
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

router.post("/reject", auth, async (req, res) => {
  try {
    const response = await inviteService.handleRejectInvite(req.body.loiMoiId);
    res.json(response);
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

router.get("/incoming", auth, async (req, res) => {
  try {
    const response = await inviteService.handleGetIncoming(req.user?.nguoidung_id);
    res.json(response);
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

router.post("/cancel", auth, async (req, res) => {
  try {
    const response = await inviteService.handleCancel(req.user.nguoidung_id, req.body.loiMoiId);
    res.json(response);
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

export default router;
