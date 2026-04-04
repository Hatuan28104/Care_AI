import express from "express";
import { auth } from "../middlewares/auth.middleware.js";
import * as healthMetricService from "../services/healthMetric.service.js";

const router = express.Router();

router.get("/ping", (req, res) => {
  res.json({
    success: true,
    message: "Health API OK",
    time: new Date().toISOString(),
  });
});

router.get("/metrics", auth, async (req, res) => {
  try {
    const response = await healthMetricService.handleGetMetrics();
    res.json(response);
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Không lấy được danh sách chỉ số" });
  }
});

router.post("/metrics", auth, async (req, res) => {
  try {
    const response = await healthMetricService.handleCreateMetric(req.body);
    res.json(response);
  } catch (err) {
    console.error(err);
    res.status(err.message === "Thiếu dữ liệu" ? 400 : 500).json({ success: false, message: err.message === "Thiếu dữ liệu" ? err.message : "Không thêm được chỉ số" });
  }
});

router.post("/device/ensure", auth, async (req, res) => {
  try {
    const response = await healthMetricService.handleDeviceEnsure(req.user);
    res.json(response);
  } catch (err) {
    console.error(err);
    res.status(err.message === "Chưa đăng nhập" ? 401 : 500).json({ success: false, message: err.message === "Chưa đăng nhập" ? err.message : "Không tạo được thiết bị" });
  }
});

router.post("/data", auth, async (req, res) => {
  try {
    const response = await healthMetricService.handleSaveData(req.user, req.body);
    res.json(response);
  } catch (err) {
    console.error(err);
    res.status(err.message === "Chưa đăng nhập" ? 401 : 500).json({ success: false, message: err.message || "Không lưu được dữ liệu" });
  }
});

router.get("/data/latest/device/:deviceId", auth, async (req, res) => {
  try {
    const response = await healthMetricService.handleGetLatestDeviceData(req.params.deviceId);
    res.json(response);
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Không lấy được dữ liệu device" });
  }
});

router.get("/data/latest/user", auth, async (req, res) => {
  try {
    const response = await healthMetricService.handleGetLatestUserData(req.user);
    res.json(response);
  } catch (err) {
    console.error(err);
    res.status(err.message === "Chưa đăng nhập" ? 401 : 500).json({ success: false, message: err.message === "Chưa đăng nhập" ? err.message : "Không lấy được dữ liệu user" });
  }
});

router.get("/ai-insight/latest", auth, async (req, res) => {
  try {
    const response = await healthMetricService.handleGetLatestAIInsight(req.user);
    res.json(response);
  } catch (err) {
    console.error(err);
    res.status(err.message === "Chưa đăng nhập" ? 401 : 500).json({ success: false, message: err.message === "Chưa đăng nhập" ? err.message : "Không lấy được AI Insight" });
  }
});

router.get("/history/user/:metricId", auth, async (req, res) => {
  try {
    const response = await healthMetricService.handleGetHistoryByUser(req.user, req.params.metricId, req.query.range);
    res.json(response);
  } catch (err) {
    console.error(err);
    res.status(err.message === "Chưa đăng nhập" ? 401 : 500).json({ success: false, message: err.message === "Chưa đăng nhập" ? err.message : "Không lấy được lịch sử user" });
  }
});

router.get("/history/:deviceId/:metricId", auth, async (req, res) => {
  try {
    const response = await healthMetricService.handleGetHistory(req.params.deviceId, req.params.metricId);
    res.json(response);
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Không lấy được lịch sử" });
  }
});

router.get("/report/:quanHeId", auth, async (req, res) => {
  try {
    const response = await healthMetricService.handleGetReport(req.user, req.params.quanHeId, req.query.type || "day");
    res.json(response);
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Không lấy được báo cáo" });
  }
});

export default router;