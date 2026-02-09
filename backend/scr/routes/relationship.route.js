import express from "express";
import {
  getMyGuardians,
  getMyDependents,
  endRelationship,
  getRelationshipProfile
} from "../repos/relationship.repo.js";
import { auth } from "../middlewares/auth.middleware.js";

const router = express.Router();

/* =========================
   PROFILE QUAN HỆ (GIÁM HỘ / PHỤ THUỘC)
========================= */
router.get("/profile/:id", auth, async (req, res) => {
  try {
    const qhId = req.params.id;
    const userId = req.user.NguoiDung_ID;

    const data = await getRelationshipProfile(qhId, userId);
    res.json({ success: true, data });
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

/* =========================
   DANH SÁCH NGƯỜI GIÁM HỘ
========================= */
router.get("/guardians", auth, async (req, res) => {
  try {
    const userId = req.user.NguoiDung_ID;
    const data = await getMyGuardians(userId);
    res.json({ success: true, data });
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

/* =========================
   DANH SÁCH NGƯỜI ĐƯỢC GIÁM HỘ
========================= */
router.get("/dependents", auth, async (req, res) => {
  try {
    const userId = req.user.NguoiDung_ID;
    const data = await getMyDependents(userId);
    res.json({ success: true, data });
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

/* =========================
   KẾT THÚC QUAN HỆ
========================= */
router.post("/end", auth, async (req, res) => {
  try {
    const { quanHeId } = req.body;
    await endRelationship(quanHeId);
    res.json({ success: true });
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

export default router;
