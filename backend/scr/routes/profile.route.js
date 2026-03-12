import express from "express";
import multer from "multer";
import path from "path";
import {
  updateProfile,
  getProfileById,
  getAllUsers,
  deleteUser,
} from "../repos/profile.repo.js";
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
/* ======================
   GET ALL USERS
====================== */
router.get("/", async (req, res) => {
  try {
    const users = await getAllUsers();

    res.json({
      success: true,
      data: users
    });

  } catch (e) {
    res.status(500).json({
      success: false,
      message: e.message
    });
  }
});



/* ======================
   UPDATE PROFILE
====================== */
router.put("/update", upload.single("avatar"), async (req, res) => {

  try {

    const avatarUrl = req.file
      ? `/uploads/avatars/${req.file.filename}`
      : undefined;

    await updateProfile({
      ...req.body,
      avatarUrl
    });

    res.json({
      success: true
    });

  } catch (e) {

   res.status(400).json({
  success: false,
  message: e.message,
  errors: e.errors || null
});

  }

});


/* ======================
   DELETE USER
====================== */
router.delete("/:id", async (req, res) => {

  try {

    await deleteUser(req.params.id);

    res.json({
      success: true
    });

  } catch (e) {

    res.status(500).json({
      success: false,
      message: e.message
    });

  }

});


/* ======================
   GET PROFILE BY ID
====================== */
router.get("/:id", async (req, res) => {

  try {

    const profile = await getProfileById(req.params.id);

    if (!profile) {
      return res.status(404).json({
        success: false,
        message: "Chưa có hồ sơ"
      });
    }

    res.json({
      success: true,
      data: profile
    });

  } catch (e) {

    res.status(500).json({
      success: false,
      message: e.message
    });

  }

});


export default router;