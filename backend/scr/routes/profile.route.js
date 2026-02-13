import express from "express";
import multer from "multer";
import path from "path";
import { updateProfile, getProfileById } from "../repos/profile.repo.js";

const router = express.Router();

/* ======================
   MULTER CONFIG
====================== */
const storage = multer.diskStorage({
  destination: "uploads/avatars",
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${req.body.nguoiDungId}-${Date.now()}${ext}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 2 * 1024 * 1024 }, // 2MB
});

/**
 * GET PROFILE
 * GET /profile/:id
 */
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    const profile = await getProfileById(id);

    // ❌ Chưa có record
    if (!profile) {
      return res.status(404).json({
        success: false,
        message: "Chưa có hồ sơ",
      });
    }

    // ❌ Có record nhưng CHƯA NHẬP THÔNG TIN
    if (
      !profile.TenND ||
      !profile.NgaySinh ||
      profile.GioiTinh === null ||
      profile.ChieuCao === null ||
      profile.CanNang === null
    ) {
      return res.status(404).json({
        success: false,
        message: "Hồ sơ chưa hoàn chỉnh",
      });
    }

    // ✅ Profile hợp lệ
    return res.json({
      success: true,
      data: profile,
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});


/* ======================
   UPDATE PROFILE
====================== */
router.put("/update", upload.single("avatar"), async (req, res) => {
  console.log("👉 req.file =", req.file);
  console.log("👉 req.body =", req.body);

  try {
    // 🔥 FIX 1: chỉ set avatarUrl khi CÓ file
    const avatarUrl = req.file
      ? `/uploads/avatars/${req.file.filename}`
      : undefined;

    await updateProfile({
      ...req.body,
      avatarUrl, // 🔥 FIX 2: truyền rõ ràng
    });

    return res.json({
      success: true,
      message: "Cập nhật hồ sơ thành công",
      avatarUrl: avatarUrl ?? null,
    });
  } catch (e) {
    return res.status(400).json({
      success: false,
      message: e.message,
      errors: e.errors || null,
    });
  }
});

export default router;