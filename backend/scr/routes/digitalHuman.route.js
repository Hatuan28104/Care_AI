import express from "express";
import { getAllDigitalHuman } from "../repos/digitalHuman.repo.js";

const router = express.Router();

router.get("/", async (req, res) => {
  try {
    const data = await getAllDigitalHuman();
    res.json({ success: true, data });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

export default router;
