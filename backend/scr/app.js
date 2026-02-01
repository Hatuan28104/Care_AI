const express = require("express");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());

// ✅ API TEST
app.get("/api/test", (req, res) => {
  res.json({
    message: "Hello from backend",
    time: new Date(),
  });
});

module.exports = app;
