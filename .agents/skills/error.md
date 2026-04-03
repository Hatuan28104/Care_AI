# ERROR HANDLING

## Nguyên tắc
- Luôn có try/catch (hoặc handler middleware)
- Không được làm crash process/server do unhandled exception
- Log chi tiết lỗi nội bộ, nhưng trả về client message an toàn

## Cấu trúc Response
```json
{
  "success": false,
  "message": "Nội dung lỗi thân thiện với người dùng"
}
```

## HTTP Status code chuẩn
- **400 Bad Request:** Lỗi validation, thiếu input, sai format.
- **401 Unauthorized:** Chức năng yêu cầu đăng nhập, thiếu token, token sai.
- **403 Forbidden:** Đã đăng nhập nhưng không đủ quyền thực hiện hành động.
- **404 Not Found:** Không tìm thấy tài nguyên.
- **500 Internal Server Error:** Lỗi logic bên trong server/database.