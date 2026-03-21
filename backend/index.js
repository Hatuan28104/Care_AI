import dotenv from "dotenv";
dotenv.config();

import express from "express";
import cors from "cors";
import { getDB } from "./scr/config/db.js";

getDB();

import authRoute from "./scr/routes/auth.route.js";
import profileRoute from "./scr/routes/profile.route.js";
import inviteRoute from "./scr/routes/invite.route.js";
import relationshipRoute from "./scr/routes/relationship.route.js";
import permissionRoute from "./scr/routes/permission.route.js";
import settingsRoute from "./scr/routes/settings.route.js";
import notificationRoute from "./scr/routes/notification.route.js";
import healthMetricRoute from "./scr/routes/healthMetric.route.js";
import chatRoute from "./scr/routes/chat.route.js";
import digitalHumanRoute from "./scr/routes/digitalHuman.route.js";

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

/* ===== PORT (QUAN TRỌNG NHẤT) ===== */
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log("🚀 Backend running on port " + PORT);
});