# API DESIGN

## Nguyên tắc
- RESTful chuẩn
- Dùng đúng method (GET, POST, PUT, DELETE)

## Response format
{
  success: true,
  data: ...
}

## Error format
{
  success: false,
  message: "..."
}

## Quy tắc
- Không đổi response cũ
- Validate input
- Không viết logic trong route