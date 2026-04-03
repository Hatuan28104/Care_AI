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

## Quy tắc
- Luôn xác định module dựa trên path file đang làm
- Chỉ áp dụng rule của module đó
- Không trộn logic giữa các module

## Ràng buộc
- Backend → không chứa UI code  
- Frontend → không chứa business logic phức tạp  
- AI service → không chứa API/controller Web  
- Mobile → không xử lý logic backend  

## Nếu không xác định được module
- Hỏi lại trước khi code  
- Không tự suy đoán  

## Ưu tiên
- Luôn giữ logic đúng module  
- Tuân theo cấu trúc mong muốn của project (đặc biệt: Backend theo pattern Route/Service/Repo)