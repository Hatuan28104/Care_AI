import jwt from "jsonwebtoken";

export function auth(req, res, next) {
    console.log('🔥 AUTH HEADER =', req.headers.authorization);
 
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ success: false, message: "Chưa đăng nhập" });
  }

  const token = authHeader.split(" ")[1];
  try {
const decoded = jwt.verify(token, "my_secret_key");
    req.user = decoded; 
    next();
  } catch (e) {
    return res.status(401).json({ success: false, message: "Token không hợp lệ" });
  }
}
