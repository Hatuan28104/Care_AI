import express from "express";
import { auth } from "../middlewares/auth.middleware.js";

import {
  getAllHealthMetrics,
  createHealthMetric,
  getLatestHealthDataByDevice,
  getLatestHealthDataByUser,
  getHealthHistory,
  getHealthHistoryByUser,
  getHealthReport,
  ensureDeviceForUser,
  saveMultipleHealthData, 
} from "../repos/healthMetric.repo.js";

const router = express.Router();

/* =========================
   PING - Test API
========================= */
router.get("/ping", (req, res) => {
  res.json({
    success: true,
    message: "Health API OK",
    time: new Date().toISOString(),
  });
});

/* =========================
   LẤY DANH SÁCH CHỈ SỐ
========================= */
router.get("/metrics", auth, async (req, res) => {
  try {
    const data = await getAllHealthMetrics();
    res.json({ success: true, data });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Không lấy được danh sách chỉ số",
    });
  }
});

/* =========================
   THÊM CHỈ SỐ MỚI
========================= */
router.post("/metrics", auth, async (req, res) => {
  try {
    const loaichiso_id =
      req.body.loaichiso_id ?? req.body.LoaiChiSo_ID;
    const tenchiso =
      req.body.tenchiso ?? req.body.TenChiSo;
    const donvido =
      req.body.donvido ?? req.body.DonViDo;
    const category =
      req.body.category ?? req.body.Category;

    if (!loaichiso_id || !tenchiso || !donvido) {
      return res.status(400).json({
        success: false,
        message: "Thiếu dữ liệu",
      });
    }

    await createHealthMetric({
      loaichiso_id,
      tenchiso,
      donvido,
      category,
    });

    res.json({
      success: true,
      message: "Đã thêm chỉ số",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Không thêm được chỉ số",
    });
  }
});

/* =========================
   LẤY/TẠO THIẾT BỊ USER
========================= */
router.post("/device/ensure", auth, async (req, res) => {
  try {
    const nguoiDungId =
      req.user?.NguoiDung_ID || req.user?.nguoidung_id;

    if (!nguoiDungId) {
      return res.status(401).json({
        success: false,
        message: "Chưa đăng nhập",
      });
    }

    const thietBiId = await ensureDeviceForUser(nguoiDungId);

    res.json({
      success: true,
      data: { ThietBi_ID: thietBiId },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Không tạo được thiết bị",
    });
  }
});

/* =========================
   LƯU DỮ LIỆU SỨC KHỎE (CHUẨN)
========================= */
router.post("/data", auth, async (req, res) => {
  try {
    const nguoiDungId =
      req.user?.NguoiDung_ID || req.user?.nguoidung_id;

    if (!nguoiDungId) {
      return res.status(401).json({
        success: false,
        message: "Chưa đăng nhập",
      });
    }

    let thietbi_id = req.body.thietbi_id ?? req.body.ThietBi_ID;

    // 🔥 đảm bảo có device
    if (!thietbi_id) {
      thietbi_id = await ensureDeviceForUser(nguoiDungId);
    }

    if (!thietbi_id) {
      return res.status(400).json({
        success: false,
        message: "Thiếu ThietBi_ID",
      });
    }

    // 🔥 chỉ dùng 1 hàm duy nhất
    await saveMultipleHealthData({
      ...req.body,
      nguoidung_id: nguoiDungId,
      thietbi_id,
    });

    res.json({
      success: true,
      message: "Đã lưu dữ liệu sức khỏe",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: err.message || "Không lưu được dữ liệu",
    });
  }
});

/* =========================
   DATA MỚI NHẤT
========================= */
router.get("/data/latest/device/:deviceId", auth, async (req, res) => {
  try {
    const { deviceId } = req.params;

    const data = await getLatestHealthDataByDevice(deviceId);

    res.json({ success: true, data });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Không lấy được dữ liệu device",
    });
  }
});
router.get("/data/latest/user", auth, async (req, res) => {
  try {
    const nguoiDungId =
      req.user?.NguoiDung_ID || req.user?.nguoidung_id;

    if (!nguoiDungId) {
      return res.status(401).json({
        success: false,
        message: "Chưa đăng nhập",
      });
    }

    const data = await getLatestHealthDataByUser(nguoiDungId);

    res.json({ success: true, data });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Không lấy được dữ liệu user",
    });
  }
});
/* =========================
   HISTORY
========================= */
router.get("/history/:deviceId/:metricId", auth, async (req, res) => {
  try {
    const { deviceId, metricId } = req.params;
    const data = await getHealthHistory(deviceId, metricId);
    res.json({ success: true, data });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Không lấy được lịch sử",
    });
  }
});

router.get("/history/user/:metricId", auth, async (req, res) => {
  try {
    const { metricId } = req.params;
    const nguoiDungId =
      req.user?.NguoiDung_ID || req.user?.nguoidung_id;

    if (!nguoiDungId) {
      return res.status(401).json({
        success: false,
        message: "Chưa đăng nhập",
      });
    }

    const data = await getHealthHistoryByUser(nguoiDungId, metricId);
    res.json({ success: true, data });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Không lấy được lịch sử user",
    });
  }
});

/* =========================
   REPORT
========================= */
router.get("/report/:deviceId", auth, async (req, res) => {
  try {
    const { deviceId } = req.params;
    const { type } = req.query;

    const data = await getHealthReport(deviceId, type);
    res.json({ success: true, data });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Không lấy được báo cáo sức khỏe",
    });
  }
});

export default router;