# SUPABASE QUERY

## Nguyên tắc
- Ưu tiên sử dụng query SDK chuẩn: `supabase.from('bảng').select('*')`
- Kiểm tra kết quả trả về `data`, `error`.
- Không throw ngầm nếu quên check `error`.

## Xử lý dữ liệu
- Bắt buộc kiểm tra `if (error) throw new Error(error.message)`
- Check return limit và pagination nếu list lớn.
