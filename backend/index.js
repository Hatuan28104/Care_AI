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