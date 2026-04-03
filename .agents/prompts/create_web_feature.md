[AGENT: frontend]

Task: {{task}}

Input:
- {{feature_request}}

Context:
- ../context.md

Rules:
- ../rules.md

Skills:
- architecture
- validation
- error

Yêu cầu:
- Xây dựng giao diện bằng HTML/CSS/JS thuần
- Áp dụng các class CSS hiện có, kế thừa thiết kế gốc
- Tuyệt đối không thêm/tự cài đặt fw như React, Vue, tailwind nếu không có trong base
- Tối ưu UI/UX, responsive cho web
- Gọi nội bộ tới API backend (nếu có)

Output:
1. Phân tích UI/UX/Logic
2. Trình bày các file bị ảnh hưởng
3. Code Layout & Logic
4. Căn chỉnh hiển thị Browser
