import dotenv from "dotenv";
dotenv.config();

import express from "express";
import cors from "cors";
import { getDB } from "./src/config/db.js";

getDB();

import authRoute from "./src/routes/auth.route.js";
import profileRoute from "./src/routes/profile.route.js";
import inviteRoute from "./src/routes/invite.route.js";
import relationshipRoute from "./src/routes/relationship.route.js";
import permissionRoute from "./src/routes/permission.route.js";
import settingsRoute from "./src/routes/settings.route.js";
import notificationRoute from "./src/routes/notification.route.js";
import healthMetricRoute from "./src/routes/healthMetric.route.js";
import chatRoute from "./src/routes/chat.route.js";
import digitalHumanRoute from "./src/routes/digitalHuman.route.js";

const app = express();

app.use(cors());
app.use(express.json());

/* ===== ROUTES ===== */
app.use("/profile", profileRoute);
app.use("/notification", notificationRoute);
app.use("/family/invite", inviteRoute);
app.use("/family/relationship", relationshipRoute);
app.use("/family/permission", permissionRoute);
app.use("/api/chat", chatRoute);
app.use("/api/digital-human", digitalHumanRoute);
app.use("/api/settings", settingsRoute);
app.use("/health", healthMetricRoute);
app.use("/auth", authRoute);

/* ===== STATIC ===== */
app.use("/uploads", express.static("uploads"));

/* ===== ROOT ===== */
app.get("/", (req, res) => {
  res.send("CareAI Backend running");
});

/* ===== ADD: DEBUG PING ===== */
app.get("/health/ping-test", (req, res) => {
  res.json({ success: true, message: "Ping OK" });
});

/* ===== ADD: 404 HANDLER ===== */
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `API not found: ${req.method} ${req.originalUrl}`,
  });
});

/* ===== PORT (QUAN TRỌNG NHẤT) ===== */
const PORT = process.env.PORT || 3000;

/* ===== ADD: 0.0.0.0 (để mobile gọi được) ===== */
app.listen(PORT, "0.0.0.0", () => {
  console.log("🚀 Backend running on port " + PORT);
});