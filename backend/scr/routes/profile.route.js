import express from "express";
import { updateProfile } from "../repos/profile.repo.js";

const router = express.Router();

/**
 * UPDATE PROFILE
 * PUT /profile/update
 */
router.put("/update", async (req, res) => {
  try {
    const result = await updateProfile(req.body);

    res.json({
      success: true,
      message: "Cập nhật hồ sơ thành công",
      data: result,
    });
  } catch (e) {
  res.status(400).json({
    success: false,
    message: e.message,
    errors: e.errors || null,
  });
}

});

export default router;
