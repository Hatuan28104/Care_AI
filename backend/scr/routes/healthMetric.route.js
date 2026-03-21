import express from "express";

import {
  getAllHealthMetrics,
  createHealthMetric,
  saveHealthData,
  getLatestHealthData,
  getHealthHistory,
    getHealthReport
} from "../repos/healthMetric.repo.js";

const router = express.Router();


/* =========================
   LẤY DANH SÁCH CHỈ SỐ
========================= */
router.get("/metrics", async (req, res) => {
  try {

    const data = await getAllHealthMetrics();

    res.json({
      success: true,
      data
    });

  } catch (err) {
    console.error(err);

    res.status(500).json({
      success: false,
      message: "Không lấy được danh sách chỉ số"
    });
  }
});


/* =========================
   THÊM CHỈ SỐ MỚI
========================= */
router.post("/metrics", async (req, res) => {
  try {
    const loaichiso_id = req.body.loaichiso_id ?? req.body.LoaiChiSo_ID;
    const tenchiso = req.body.tenchiso ?? req.body.TenChiSo;
    const donvido = req.body.donvido ?? req.body.DonViDo;
    const category = req.body.category ?? req.body.Category;

    if (!loaichiso_id || !tenchiso || !donvido) {
      return res.status(400).json({
        success: false,
        message: "Thiếu dữ liệu"
      });
    }

    await createHealthMetric({
      loaichiso_id,
      tenchiso,
      donvido,
      category
    });

    res.json({
      success: true,
      message: "Đã thêm chỉ số"
    });

  } catch (err) {
    console.error(err);

    res.status(500).json({
      success: false,
      message: "Không thêm được chỉ số"
    });
  }
});


/* =========================
   LƯU DỮ LIỆU SỨC KHỎE
========================= */
router.post("/data", async (req, res) => {
  try {
    const giatri = req.body.giatri ?? req.body.GiaTri;
    const thietbi_id = req.body.thietbi_id ?? req.body.ThietBi_ID;
    const loaichiso_id = req.body.loaichiso_id ?? req.body.LoaiChiSo_ID;

    if (!giatri || !thietbi_id || !loaichiso_id) {
      return res.status(400).json({
        success: false,
        message: "Thiếu dữ liệu"
      });
    }

    await saveHealthData({
      giatri,
      thietbi_id,
      loaichiso_id
    });

    res.json({
      success: true,
      message: "Đã lưu dữ liệu sức khỏe"
    });

  } catch (err) {
    console.error(err);

    res.status(500).json({
      success: false,
      message: "Không lưu được dữ liệu"
    });
  }
});
/* =========================
   LẤY DỮ LIỆU MỚI NHẤT
========================= */
router.get("/data/latest/:deviceId", async (req, res) => {
  try {

    const { deviceId } = req.params;

    const data = await getLatestHealthData(deviceId);

    res.json({
      success: true,
      data
    });

  } catch (err) {
    console.error(err);

    res.status(500).json({
      success: false,
      message: "Không lấy được dữ liệu mới nhất"
    });
  }
});


/* =========================
   LỊCH SỬ CHỈ SỐ
========================= */
router.get("/history/:deviceId/:metricId", async (req, res) => {
  try {

    const { deviceId, metricId } = req.params;

    const data = await getHealthHistory(deviceId, metricId);

    res.json({
      success: true,
      data
    });

  } catch (err) {
    console.error(err);

    res.status(500).json({
      success: false,
      message: "Không lấy được lịch sử"
    });
  }
});
/* =========================
   HEALTH REPORT
========================= */
router.get("/report/:deviceId", async (req, res) => {
  try {

    const { deviceId } = req.params;
    const { type } = req.query; // day | week | month

    const data = await getHealthReport(deviceId, type);

    res.json({
      success: true,
      data
    });

  } catch (err) {
    console.error(err);

    res.status(500).json({
      success: false,
      message: "Không lấy được báo cáo sức khỏe"
    });
  }
});
export default router;