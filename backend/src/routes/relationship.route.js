import express from "express";
import * as relationshipService from "../services/relationship.service.js";
import { auth } from "../middlewares/auth.middleware.js";

const router = express.Router();

router.get("/profile/:id", auth, async (req, res) => {
  try {
    const response = await relationshipService.handleGetRelationshipProfile(req.params.id, req.user.nguoidung_id);
    res.json(response);
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

router.get("/guardians", auth, async (req, res) => {
  try {
    const response = await relationshipService.handleGetMyGuardians(req.user.nguoidung_id);
    res.json(response);
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

router.get("/dependents", auth, async (req, res) => {
  try {
    const response = await relationshipService.handleGetMyDependents(req.user.nguoidung_id);
    res.json(response);
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

router.post("/end", auth, async (req, res) => {
  try {
    const response = await relationshipService.handleEndRelationship(req.body.quanHeId);
    res.json(response);
  } catch (e) {
    res.status(400).json({ success: false, message: e.message });
  }
});

export default router;
