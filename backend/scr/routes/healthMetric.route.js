import express from "express";
import { auth } from "../middlewares/auth.middleware.js";

import {
  getAllHealthMetrics,
  createHealthMetric,
  saveHealthData,
  getLatestHealthData,
  getHealthHistory,
  getHealthReport,
  ensureDeviceForUser,
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
    // hỗ trợ cả camelCase + PascalCase
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
      return res.status(400).json({
        success: false,
        message: "Thiếu NguoiDung_ID",
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
   LƯU DỮ LIỆU SỨC KHỎE
========================= */
router.post("/data", auth, async (req, res) => {
  try {
    let giatri = req.body.giatri ?? req.body.GiaTri;
    let thietbi_id = req.body.thietbi_id ?? req.body.ThietBi_ID;
    let loaichiso_id =
      req.body.loaichiso_id ?? req.body.LoaiChiSo_ID;
    let thoigian =
      req.body.thoigian ?? req.body.ThoiGianCapNhat;

    const nguoiDungId =
      req.user?.NguoiDung_ID || req.user?.nguoidung_id;

    // 🔥 detect multi
    const isMulti =
      req.body.hr !== undefined ||
      req.body.steps !== undefined ||
      req.body.spo2 !== undefined ||
      req.body.sleep !== undefined ||
      req.body.hrv !== undefined ||
      req.body.distance !== undefined;

    // 🔥 ensure device (dùng chung cho cả 2 case)
    if (!thietbi_id && nguoiDungId) {
      thietbi_id = await ensureDeviceForUser(nguoiDungId);
    }

    if (!thietbi_id) {
      return res.status(400).json({
        success: false,
        message: "Thiếu ThietBi_ID",
      });
    }

    // =========================
    // 🔥 MULTI
    // =========================
    if (isMulti) {
      const { saveMultipleHealthData } = await import(
        "../repos/healthMetric.repo.js"
      );

      await saveMultipleHealthData({
        ...req.body,
        nguoidung_id: nguoiDungId,
        thietbi_id,
      });

      return res.json({
        success: true,
        message: "Đã lưu dữ liệu (multi)",
      });
    }

    // =========================
    // 🔥 SINGLE (GIỮ NGUYÊN)
    // =========================

    if (giatri === undefined || giatri === null || giatri === "") {
      return res.status(400).json({
        success: false,
        message: "Thiếu GiaTri",
      });
    }

    if (!loaichiso_id) {
      return res.status(400).json({
        success: false,
        message: "Thiếu LoaiChiSo_ID",
      });
    }

    // 🔥 chuẩn ISO time
    if (!thoigian) {
      thoigian = new Date().toISOString();
    } else {
      thoigian = new Date(thoigian).toISOString();
    }

    await saveHealthData({
      GiaTri: giatri,
      ThietBi_ID: thietbi_id,
      LoaiChiSo_ID: loaichiso_id,
      ThoiGianCapNhat: thoigian,
    });

    res.json({
      success: true,
      message: "Đã lưu dữ liệu sức khỏe",
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Không lưu được dữ liệu",
    });
  }
});
/* =========================
   DATA MỚI NHẤT
========================= */
router.get("/data/latest/:deviceId", auth, async (req, res) => {
  try {
    const { deviceId } = req.params;

    const data = await getLatestHealthData(deviceId);

    res.json({ success: true, data });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Không lấy được dữ liệu mới nhất",
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