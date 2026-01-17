import express from "express";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

/* ===== MIDDLEWARE ===== */
app.use(cors());
app.use(express.json());

/* ===== DATA TẠM (IN-MEMORY) ===== */
const users = []; // 👈 giả lập database

/* ===== ROUTES ===== */

// Test server
app.get("/", (req, res) => {
  res.json({ status: "Care AI backend running" });
});

/* ===== REGISTER ===== */
app.post("/register", (req, res) => {
  const { email, password, name } = req.body;

  // 1. validate
  if (!email || !password) {
    return res.status(400).json({
      error: "Email and password are required",
    });
  }

  // 2. check trùng email
  const exists = users.find((u) => u.email === email);
  if (exists) {
    return res.status(409).json({
      error: "Email already registered",
    });
  }

  // 3. tạo user
  const user = {
    id: users.length + 1,
    email,
    password, // ⚠️ demo thôi, chưa hash
    name: name ?? "User",
    createdAt: new Date().toISOString(),
  };

  users.push(user);

  // 4. trả về cho app
  res.json({
    message: "Register success",
    user: {
      id: user.id,
      email: user.email,
      name: user.name,
    },
  });
});

/* ===== LOGIN ===== */
app.post("/login", (req, res) => {
  const { email, password } = req.body;

  const user = users.find(
    (u) => u.email === email && u.password === password
  );

  if (!user) {
    return res.status(401).json({
      error: "Invalid email or password",
    });
  }

  res.json({
    message: "Login success",
    user: {
      id: user.id,
      email: user.email,
      name: user.name,
    },
  });
});

/* ===== DEBUG (XEM DATA TẠM) ===== */
app.get("/users", (req, res) => {
  res.json(users);
});

/* ===== START SERVER ===== */
app.listen(PORT, () => {
  console.log(`🚀 Backend running at http://localhost:${PORT}`);
});
