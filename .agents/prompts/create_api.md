[AGENT: backend]

Task: {{task}}

Input:
- {{context}}

Context:
- ../context.md

Rules:
- ../rules.md

Skills:
- api_design
- service_pattern
- validation
- auth_jwt
- supabase_query
- firebase_admin
- error

Yêu cầu:
- Xác định module theo path
- Viết API theo đúng cấu trúc hiện tại
- Phân bổ code đúng 3 layer (Route, Service, Repo)
- Service KHÔNG được gọi Database trực tiếp (phải qua Repo)
- Repo CHỈ đóng vai trò tương tác Database, không chứa logic validate
- Validate input ở Service
- Xử lý lỗi
- Không làm vỡ API cũ
- Không viết logic trong route

Output:
1. Phân tích
2. Module
3. File bị ảnh hưởng
4. Giải pháp
5. Code
6. Kiểm tra
