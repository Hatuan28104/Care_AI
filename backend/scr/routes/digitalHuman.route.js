import express from "express";
import upload from "../middlewares/upload.js";

import {
  getAllDigitalHuman,
  getDigitalHumanById,
  createDigitalHuman,
  updateDigitalHuman,
  deleteDigitalHuman
} from "../repos/digitalHuman.repo.js";

const router = express.Router();

/* =========================
   GET ALL
========================= */
router.get("/", async (req, res) => {
  try {
    const data = await getAllDigitalHuman();
    res.json({ success: true, data });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

/* =========================
   GET BY ID
========================= */
router.get("/:id", async (req, res) => {
  try {
    const data = await getDigitalHumanById(req.params.id);
    res.json({ success: true, data });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

/* =========================
   CREATE
========================= */
router.post("/", upload.single("avatar"), async (req, res) => {
  try {

    const image = req.file
      ? `uploads/avatars/${req.file.filename}`
      : "";

    const data = {
      ...req.body,
      image
    };

    const result = await createDigitalHuman(data);

    res.json({ success: true, message: result.message });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

/* =========================
   UPDATE
========================= */
router.put("/:id", upload.single("avatar"), async (req, res) => {
  try {

    let image = req.body.image;

    if (req.file) {
      image = `uploads/avatars/${req.file.filename}`;
    }

    const data = {
      ...req.body,
      image
    };

    const result = await updateDigitalHuman(req.params.id, data);

    res.json({ success: true, message: result.message });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

/* =========================
   DELETE
========================= */
router.delete("/:id", async (req, res) => {
  try {
    const result = await deleteDigitalHuman(req.params.id);
    res.json({ success: true, message: result.message });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

export default router;