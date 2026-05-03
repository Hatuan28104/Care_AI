# Care_AI Project Context

## Tổng quan dự án
Care_AI là một hệ thống đa thành phần gồm:
- `ai_service/`: dịch vụ AI bằng Python (FastAPI)
- `backend/`: API server chính bằng Node.js/Express
- `mobile_app/`: ứng dụng Flutter cho nền tảng di động
- `web_admin/`: portal web tĩnh cho quản trị/cổng vào
- `tmp_healthconnect/`: thư mục chứa file native/Android hỗ trợ Health Connect (Android)

Không có README gốc ở thư mục dự án cha; chỉ có `mobile_app/README.md` là README Flutter mặc định.

## ai_service/
Mục đích: cung cấp mô hình AI cho tự đánh giá cá nhân và dự đoán căng thẳng.

Các thành phần chính:
- `app.py`: FastAPI entrypoint
  - nạp model từ `SELF_EVOLUTION_MODEL_PATH`, `STRESS_MODEL_PATH`, `STRESS_SCALER_PATH`
  - đăng ký router API của `self_evolution` và `stress_prediction`
- `settings.py`: cấu hình biến môi trường/đường dẫn model
- `self_evolution/`: logic tự phát triển cá nhân
  - `self_evolution_router.py`, `self_evolution_service.py`, `train.py`, `preprocess.py`, `utils.py`
- `stress_prediction/`: mô hình dự đoán stress
  - `stress_route.py`, `stress_service.py`, `train.py`
- Dữ liệu mẫu: `wearables_health_6mo_daily.csv`

## backend/
Mục đích: API server chính, cung cấp dữ liệu người dùng, thông báo, chat, digital human, health metrics, xác thực...

Kiến trúc:
- `index.js`: entrypoint Express
  - middleware `cors`, `express.json()`
  - static file `uploads`
  - routes: `/profile`, `/notification`, `/family/*`, `/api/chat`, `/api/digital-human`, `/api/settings`, `/health`, `/auth`
  - 404 fallback và `/health/ping-test`
- `package.json`: dependencies chính
  - `express`, `cors`, `dotenv`, `firebase-admin`, `multer`, `openai`, `@supabase/supabase-js`
- `src/config/db.js`: kết nối Supabase
- `src/middlewares/`: xác thực JWT và upload
- `src/routes/`: các route API
- `src/services/`, `src/repos/`: logic nghiệp vụ và truy vấn dữ liệu

## mobile_app/
Mục đích: ứng dụng Flutter di động, tích hợp Firebase, thông báo đẩy, Bluetooth, camera, local storage.

Hiện trạng:
- `lib/main.dart`: entrypoint Flutter
  - khởi tạo Firebase
  - cấu hình Firebase Messaging foreground/background
  - đăng ký token FCM và gửi đến `/auth/save-fcm-token`
  - lấy profile khi đã login
- `lib/api/`: các API client (ví dụ `auth_api.dart`, `profile_api.dart`)
- `lib/config/api_config.dart`: cấu hình base URL API server
- `lib/screens/`: giao diện chính
  - `intro_screen.dart`, `AuthScreen/`, `home/`, `settings/`, `welcome_screen.dart`
- `lib/app_settings.dart`: cấu hình app, locale, text scaling
- `lib/firebase_options.dart`: cấu hình Firebase platforms
- `pubspec.yaml`: dependencies Flutter
  - `http`, `shared_preferences`, `firebase_core`, `firebase_messaging`, `flutter_local_notifications`, `flutter_blue_plus`, `permission_handler`, `speech_to_text`, `intl_phone_field`, `phone_numbers_parser`

## web_admin/
Mục đích: giao diện web quản trị/cổng auth.

Cấu trúc:
- `index.html`: trang tải và chuyển hướng tới `pages/auth/auth.html`
- `assets/`: CSS, JS, hình ảnh
- `pages/`: trang auth, dashboard, digital, setting, user
- Tập trung vào portal tĩnh, có thể hoạt động như SPA bằng JS riêng.

## tmp_healthconnect/
- Thư mục chứa tài nguyên Android gốc và cấu hình Health Connect
- Dùng để tích hợp với Android native, có thể là hỗ trợ dữ liệu sức khỏe từ thiết bị Wear OS/Health Connect.

## Chạy và môi trường
### ai_service
- Python + FastAPI
- Nên có `joblib` và các đường dẫn model cấu hình trong `settings.py`
- Dịch vụ AI chạy độc lập, dùng API `/self` và `/stress`

### backend
- Node.js 18+ (ES module)
- Cần `.env` với `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, các biến Firebase nếu dùng admin
- Chạy `npm install` và `npm start`

### mobile_app
- Flutter SDK 3.x
- Cần cấu hình Firebase bằng `firebase_options.dart`
- Chạy `flutter pub get`, sau đó `flutter run`

## Ghi chú quan trọng
- Repo chưa có tài liệu tổng thể ở root.
- Backend sử dụng Supabase cho DB/ứng dụng và Firebase Admin cho thông báo.
- Mobile app kết hợp Firebase Messaging, local storage, Bluetooth và health metrics.
- `ai_service` là phần AI chuyên biệt, tách riêng với backend chính.

## Tổng kết
Care_AI là một hệ thống đa phần, gồm:
- Dịch vụ AI / ML với FastAPI
- API server Node.js/Express cho bảo mật và nghiệp vụ
- Ứng dụng Flutter đa nền tảng cho người dùng
- Portal web tĩnh cho admin/quản trị
- Hỗ trợ tích hợp Health Connect/Android native

Tệp `context.md` này giúp nhanh chóng nắm bắt bức tranh tổng thể và điểm chạm chính giữa các module.