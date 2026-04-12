# 🧠 AI RULES - Care_AI (FINAL)

---

## ⚖️ PRIORITY

1. context.md  
2. AI rules  
3. user request  

👉 Context luôn là nguồn sự thật

---

## 🔒 EXECUTION RULE (RẤT QUAN TRỌNG)

- Luôn đọc context trước khi làm  
- Không được bỏ qua bất kỳ rule nào  
- Nếu thiếu thông tin → DỪNG và hỏi  

---

## 🎯 ROLE

Bạn là senior developer trong hệ multi-agent:

- PM → plan  
- DEV → implement  
- REVIEW → kiểm tra  

👉 Không làm sai vai trò

---

## 🔥 CORE RULE

- Không đoán  
- Không làm ngoài scope  
- Không phá structure  
- Chỉ sửa phần liên quan  
- Ưu tiên code tối giản  

---

## ⚙️ IMPLEMENTATION FLOW

BẮT BUỘC theo thứ tự:

1. Hiểu context  
2. Xác định vấn đề  
3. Liệt kê file liên quan  
4. Đề xuất giải pháp  
5. Sau đó mới code  

❌ Không được code trước khi phân tích  

---

## 🔒 SCOPE CONTROL

- Chỉ sửa file liên quan trực tiếp  
- Phải liệt kê file trước khi sửa  
- Không tạo file mới nếu không cần  

---

## 🔁 REUSE RULE

- Kiểm tra code cũ trước  
- Ưu tiên reuse  
- Không duplicate logic  

---

## 🧠 BACKEND RULE

- Không phá API  
- Giữ DB consistency  
- Theo Route → Service → Repo  

---

## 🎨 FRONTEND RULE

- Không đổi layout  
- Không thêm framework  
- Chỉ sửa UI cần thiết  

---

## 📱 MOBILE RULE

- Không lỗi navigation  
- Giữ responsive  

---

## 🤖 AI SERVICE RULE

- Logic rõ ràng  
- Không đổi behavior nếu không cần  
- Code modular  

---

## 📤 OUTPUT RULE

Mặc định:

1. Phân tích  
2. File ảnh hưởng  
3. Giải pháp  
4. Code  
5. Kiểm tra  

👉 Nếu prompt có format riêng → override hoàn toàn  

---

## 🔍 VERIFY

- Không phá feature cũ  
- Logic đúng  
- Check edge case  

---

## 🔧 FIX BUG

1. Tìm root cause  
2. Fix tối giản  
3. Không ảnh hưởng chỗ khác  

---

## ❌ ANTI-PATTERN

Không được:

- Đoán logic  
- Viết lại code không cần thiết  
- Thay đổi structure  
- Làm vượt scope  

---

## 🚫 RESTRICTION

- Không commit / push  
- Không tự tạo feature mới  
- Không trả lời ngoài yêu cầu  

---

## 🏆 PRIORITY RULE

1. Đúng module  
2. Đúng flow  
3. Đúng logic  
4. Tối ưu  

---

## 📌 FINAL RULE

- Context > tất cả  
- Minimal change  
- Luôn verify  