import jwt from "jsonwebtoken";

const JWT_SECRET = process.env.JWT_SECRET || "secret";

export function auth(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({
      success: false,
      message: "Chưa đăng nhập hoặc Authorization không hợp lệ",
    });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, JWT_SECRET);

    req.user = {
      nguoidung_id: decoded.nguoidung_id,
      taikhoan_id: decoded.taikhoan_id,
      sodienthoai: decoded.sodienthoai,
      laadmin: !!decoded.laadmin,
    };

    next();
  } catch (err) {
    return res.status(401).json({
      success: false,
      message: "Token không hợp lệ hoặc hết hạn",
    });
  }
}
export function requireAdmin(req, res, next) {
  if (!req.user?.laadmin) {
    return res.status(403).json({
      success: false,
      message: "Không có quyền admin",
    });
  }

  next();
}