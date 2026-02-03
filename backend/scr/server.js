import express from "express";
import authRoute from "./routes/auth.route.js";
import profileRoute from "./routes/profile.route.js";

const app = express();

// ❌ KHÔNG parse JSON GLOBAL
// app.use(express.json());

// profile có upload → multer tự xử lý
app.use("/profile", profileRoute);

// auth chỉ dùng JSON → parse tại đây
app.use("/auth", express.json(), authRoute);

app.use("/uploads", express.static("uploads"));

app.get("/", (req, res) => {
  res.send("CareAI Backend running");
});

app.listen(3000, () => {
  console.log("🚀 Backend running at http://localhost:3000");
});
