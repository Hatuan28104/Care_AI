# 🧩 MODULE DETECTION & CONTEXT

Project: Care_AI

## Tech Stack Hiện Tại
- **/backend (Node.js)**: Xây dựng API, tương tác Database. Kiến trúc: Route/Service/Repo.
- **/web_admin (Vanilla web)**: HTML/CSS/JS thuần, không sử dụng framework (React/Vue/Angular).
- **/mobile_app (Flutter/Dart)**: Ứng dụng điện thoại, tuân thủ UI responsive và navigation stack.
- **/ai_service (Python)**: Xử lý logic AI, phân tích dữ liệu chuyên sâu.

---

## Database & Data Flow
- **Supabase (PostgreSQL)**: Dùng làm Database chính lưu trữ dữ liệu người dùng, logic quan hệ. Sử dụng @supabase/supabase-js để query.
- **Firebase Admin**: Dùng để quản lý thông báo đẩy (FCM), lưu log hoặc xác thực (OTP/Login) nếu cần.

### Flow Cơ Bản
1. Mobile/Web client gửi request lên Backend Node.js
2. Route nhận request -> chuyển cho Service xử lý business logic & validate -> Service gọi Repo.
3. Repo thực hiện query giao tiếp trực tiếp với Supabase/Firebase (Service KHÔNG query DB trực tiếp).
4. Trả về JSON chuẩn ({ success, data/message }) qua Route.
5. Các task nặng hoặc phân tích dữ liệu sẽ giao cho AI Service.

---
## 🔍 MODULE DETECTION (BẮT BUỘC)

### Theo path:
- `/backend` → Backend
- `/web_admin` → Frontend
- `/mobile_app` → Mobile
- `/ai_service` → AI

### Nếu không có path:
- Node.js → Backend
- HTML/CSS/JS → Frontend
- Dart → Mobile
- Python → AI

### Nếu không chắc:
- Hỏi lại
- ❌ KHÔNG tự đoán

---

## ⚙️ ACTION RULE

- Chỉ áp dụng rule của module đã xác định
- Không viết code ngoài module
- Nếu yêu cầu vượt module:
  → DỪNG và yêu cầu làm rõ
  → KHÔNG tự triển khai

## Ràng buộc
- Backend → không chứa UI code  
- Frontend → không chứa business logic phức tạp  
- AI service → không chứa API/controller Web  
- Mobile → không xử lý logic backend  

---

## 🧠 BACKEND RULE (BẮT BUỘC)

- Route → nhận request, trả response
- Service → logic + validation
- Repo → query DB

❌ Service không query DB  
❌ Route không chứa logic  

---

## 📤 OUTPUT RULE

- Backend → JSON
- Frontend → HTML/CSS/JS
- Mobile → Dart
- AI → Python

---

## ⚠️ VALIDATION & ERROR

- Validate input (required, type, format)
- Không tin client
- Dùng try/catch
- Không crash server

---

## 🧪 TESTING (CHO REVIEW)

- Check null / empty / invalid
- Không bỏ sót edge case

---

## 🏆 PRIORITY (QUAN TRỌNG)

1. Đúng module
2. Đúng flow (Route → Service → Repo)
3. Đúng logic
4. Tối ưu

❗ Sai module = không chấp nhận

---

## ❗ FINAL RULE

- Không đoán
- Không thêm feature
- Không phá kiến trúc
- Thiếu thông tin → hỏi lại
## 📌 NOTE

- Luôn đọc toàn bộ context trước khi trả lời