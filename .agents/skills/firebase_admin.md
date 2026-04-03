# FIREBASE ADMIN

## Định hướng
- Dành cho các tính năng: Push Notification (FCM), Auth (Custom Token) hoặc tham chiếu log Firestore/Realtime.
- Không lạm dụng Firebase DB nếu dữ liệu chính rdbms nên nằm ở Supabase.

## Convention Firebase
- Fetch hoặc Update thông qua SDK `firebase-admin`.
- Bắt lỗi riêng biệt trong try/catch để trả message cho người dùng.
