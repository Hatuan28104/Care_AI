import express from "express";
import {
  getMyGuardians,
  getMyDependents,
  endRelationship
} from "../repos/relationship.repo.js";
import { auth } from "../middlewares/auth.middleware.js";

const router = express.Router();

router.get("/guardians",auth, async (req, res) => {
  try {
    const userId = req.user.NguoiDung_ID;
    const data = await getMyGuardians(userId);
    res.json({ success: true, data });
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

router.get("/dependents", auth, async (req, res) => {
  try {
    const userId = req.user.NguoiDung_ID;
    const data = await getMyDependents(userId);
    res.json({ success: true, data });
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

router.post("/end", async (req, res) => {
  try {
    const { quanHeId } = req.body;
    await endRelationship(quanHeId);
    res.json({ success: true });
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

export default router;
