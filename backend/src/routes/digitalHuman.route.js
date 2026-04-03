import express from "express";
import upload from "../middlewares/upload.js";
import * as digitalHumanService from "../services/digitalHuman.service.js";

const router = express.Router();

router.get("/", async (req, res) => {
  try {
    const response = await digitalHumanService.handleGetAll();
    res.json(response);
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.get("/:id", async (req, res) => {
  try {
    const response = await digitalHumanService.handleGetById(req.params.id);
    res.json(response);
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.post("/", upload.single("avatar"), async (req, res) => {
  try {
    const response = await digitalHumanService.handleCreate(req.file, req.body);
    res.json(response);
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.put("/:id", upload.single("avatar"), async (req, res) => {
  try {
    const response = await digitalHumanService.handleUpdate(req.params.id, req.file, req.body);
    res.json(response);
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.delete("/:id", async (req, res) => {
  try {
    const response = await digitalHumanService.handleDelete(req.params.id);
    res.json(response);
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

export default router;