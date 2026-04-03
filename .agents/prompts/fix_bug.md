[AGENT: debug]

Task: fix bug

Input:
{{bug}}

Context:
- ../context.md

Rules:
- ../rules.md

Skills:
- error
- validation

Yêu cầu:
- Xác định module theo path
- Tìm root cause
- Fix tối giản
- Không ảnh hưởng phần khác

Output:
1. Nguyên nhân
2. Module
3. File bị ảnh hưởng
4. Cách fix
5. Code
6. Kiểm tra
