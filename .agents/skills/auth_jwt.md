# JWT AUTH

## Flow
1. Login → tạo access + refresh token
2. Request → verify access token
3. Hết hạn → dùng refresh token

## Middleware
- Lấy token từ header: Bearer
- Verify token
- Gắn user vào request

## Quy tắc
- Không hardcode secret
- Access token ngắn hạn
- Không log token