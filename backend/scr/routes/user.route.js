import express from "express";
import { getAllUsers } from "../repos/user.repo.js";

const router = express.Router();

router.get("/", async (req, res) => {
  res.json(await getAllUsers());
});

export default router;
