import dotenv from "dotenv";
dotenv.config();

import express from "express";

import authRoute from "./routes/auth.route.js";
import profileRoute from "./routes/profile.route.js";

import inviteRoute from "./routes/invite.route.js";
import relationshipRoute from "./routes/relationship.route.js";
import permissionRoute from "./routes/permission.route.js";
import settingsRoute from "./routes/settings.route.js";
import notificationRoute from "./routes/notification.route.js";
import healthMetricRoute from "./routes/healthMetric.route.js";
import chatRoute from "./routes/chat.route.js";
import digitalHumanRoute from "./routes/digitalHuman.route.js";

const app = express();

// middleware chung
app.use(express.json());

/* ===== PROFILE ===== */
app.use("/profile", profileRoute);

/* ===== NOTIFICATION ===== */
app.use("/notification", notificationRoute);

/* ===== FAMILY CENTER ===== */
app.use("/family/invite", inviteRoute);
app.use("/family/relationship", relationshipRoute);
app.use("/family/permission", permissionRoute);

/* ===== CHAT ===== */
app.use("/api/chat", chatRoute);
app.use("/api/digital-human", digitalHumanRoute);

/* ===== SETTINGS ===== */
app.use("/api/settings", settingsRoute);

/* ===== HEALTH ===== */
app.use("/health", healthMetricRoute);

/* ===== AUTH ===== */
app.use("/auth", authRoute);

/* ===== STATIC FILE ===== */
app.use("/uploads", express.static("uploads"));

app.get("/", (req, res) => {
  res.send("CareAI Backend running");
});

app.listen(3000, () => {
  console.log("🚀 Backend running at http://localhost:3000");
});