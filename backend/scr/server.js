import express from "express";

import authRoute from "./routes/auth.route.js";
import profileRoute from "./routes/profile.route.js";

import inviteRoute from "./routes/invite.route.js";
import relationshipRoute from "./routes/relationship.route.js";
import permissionRoute from "./routes/permission.route.js";

const app = express();

// middleware chung
app.use(express.json());

// ===== FAMILY CENTER =====
app.use("/family/invite", inviteRoute);
app.use("/family/relationship", relationshipRoute);
app.use("/family/permission", permissionRoute);

// ===== PROFILE =====
app.use("/profile", profileRoute);

// ===== AUTH =====
app.use("/auth", authRoute);

// static
app.use("/uploads", express.static("uploads"));

app.get("/", (req, res) => {
  res.send("CareAI Backend running");
});

app.listen(3000, () => {
  console.log("🚀 Backend running at http://localhost:3000");
});
