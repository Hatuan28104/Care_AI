# BỘ PATTERN BACKEND (Route -> Service -> Repo)

## Tổng quan
Backend bắt buộc tuân theo kiến trúc 3 lớp để đảm nhiệm tính tái sử dụng, dễ bảo trì và phân rã các logic phức tạp một cách độc lập hoàn toàn.

## Ranh giới Module
Mỗi layer có một vai trò riêng biệt, tuyệt đối KHÔNG được chồng lấn.

### 1. Route Layer (`routes/*.route.js`)
- Nhận HTTP Request từ Client (lấy parameters, req.body, headers).
- Cấu hình Midleware (ví dụ auth middleware).
- **CHỈ ĐƯỢC** truyền tham số cho Service tương ứng và chờ kết quả trả về.
- Gửi trả Response JSON, hoặc cấu hình khối catch để trả về các HTTP code tương xứng khi bị lỗi (400, 401, 500...).
- 👉 **QUY LUẬT TỐI THƯỢNG**: Tuyệt đối không có bất kì dòng `if(!param) throw` hay logic xử lý mảng, nghiệp vụ nào tại Route.

### 2. Service Layer (`services/*.service.js`)
- Chịu trách nhiệm thực thi toàn bộ **Business Logic** và **Validate dữ liệu**.
- Nhận dữ liệu truyền từ Route, kiểm tra điều kiện (ví dụ thiều `phone` => throw Error("Thiếu số")).
- Gọi một hoặc nhiều method từ Repo để tính toán kết quả.
- Tổng hợp / Format Data dạng chuẩn để Route trả thẳng bằng lệnh `res.json()`.
- 👉 **QUY LUẬT TỐI THƯỢNG**: Khuyến khích throw "string" Error hoặc Custom Error Object. Tuyệt đối **KHÔNG Query Database** (Supabase/Firebase) ngay trong file service. Chỉ gọi hàm query từ layers Repo.

### 3. Repository Layer (`repos/*.repo.js`)
- Vùng độc quyền duy nhất được làm việc với các hệ mã DB (Supabase API / Firebase Admin).
- Lớp này không quan tâm Data/Req đến từ đâu, chỉ có input và Database query.
- 👉 **QUY LUẬT TỐI THƯỢNG**: Không chứa validate nghiệp vụ tại Repo (VD không validate user id empty tại đây vì Service đã phải chặn rồi). Thao tác DB lỗi -> Throw DB Error.
