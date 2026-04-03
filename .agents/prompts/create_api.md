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
- validation
- auth_jwt
- supabase_query
- firebase_admin
- error

Yêu cầu:
- Xác định module theo path
- Viết API theo structure hiện tại
- Validate input
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
