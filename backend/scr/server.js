import express from "express";
import authRoute from "./routes/auth.route.js";
import profileRoute from "./routes/profile.route.js";

const app = express();

app.use(express.json());

// Routes
app.use("/auth", authRoute);
app.use("/profile", profileRoute);

// Health check
app.get("/", (req, res) => {
  res.send("CareAI Backend running");
});

app.listen(3000, () => {
  console.log("🚀 Backend running at http://localhost:3000");
});
