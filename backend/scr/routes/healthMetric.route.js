import express from "express";

import {
  getAllHealthMetrics,
  createHealthMetric,
  saveHealthData,
  getLatestHealthData,
  getHealthHistory
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

    const { LoaiChiSo_ID, TenChiSo, DonViDo, Category } = req.body;

    if (!LoaiChiSo_ID || !TenChiSo || !DonViDo) {
      return res.status(400).json({
        success: false,
        message: "Thiếu dữ liệu"
      });
    }

    await createHealthMetric({
      LoaiChiSo_ID,
      TenChiSo,
      DonViDo,
      Category
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

    const { GiaTri, ThietBi_ID, LoaiChiSo_ID } = req.body;

    if (!GiaTri || !ThietBi_ID || !LoaiChiSo_ID) {
      return res.status(400).json({
        success: false,
        message: "Thiếu dữ liệu"
      });
    }

    await saveHealthData({
      GiaTri,
      ThietBi_ID,
      LoaiChiSo_ID
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

export default router;