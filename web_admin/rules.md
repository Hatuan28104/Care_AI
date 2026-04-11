# Frontend Rules - Care AI Project (Project-wide)

> Version: 1.0  
> Scope: Áp dụng cho **toàn bộ frontend** trong project `AG`

---

## 1) Mục tiêu

Đảm bảo toàn bộ ứng dụng có:

- Layout thống nhất (Sidebar + Header dùng chung)
- UI đồng bộ giữa các module (`dashboard`, `user`, `digital`, `setting`, ...)
- Code sạch, dễ maintain, dễ mở rộng
- Hạn chế regressions khi thêm màn mới

---

## 2) Cấu trúc layout chuẩn (BẮT BUỘC)

### 2.1. HTML skeleton chuẩn cho mọi page

```html
<body class="{module}-page">
  <div class="dashboard-layout">
    <div id="sidebar-target"></div>

    <div class="dashboard-content">
      <div id="header-target"></div>

      <main class="main-body animate-fade-in">
        <!-- Page content -->
      </main>
    </div>
  </div>
</body>
```

### 2.2. Layout injection

- Sidebar/Header **không viết cứng** trong từng page
- Bắt buộc dùng `layout.js` để inject
- Mọi page phải include:
  - `../layout/layout.js` (defer)
  - `../assets/css/global.css`

### 2.3. Cấm

- ❌ Duplicate sidebar/header ở mỗi file
- ❌ Tạo layout riêng phá cấu trúc chung
- ❌ Đổi class lõi layout (`dashboard-layout`, `dashboard-content`, `main-body`) nếu chưa thống nhất toàn project

---

## 3) Navigation & routing

- Dùng relative path đúng theo module
- Sidebar phải highlight đúng active route
- Link điều hướng phải nhất quán giữa các page list/view/edit/add
- Không để dead link

### Chuẩn tên trang trong module

- `module.html` (list)
- `module-view.html`
- `module-edit.html`
- `module-add.html` (nếu có)

Ví dụ:
- `user/user.html`, `user/user-view.html`, `user/user-edit.html`
- `digital/digital.html`, `digital/digital-view.html`, ...

---

## 4) Design System

### 4.1. Global tokens

Toàn bộ token dùng trong `assets/css/global.css`:

- Color variables
- Typography scale
- Border radius
- Shadow
- Transition
- Spacing scale

### 4.2. Spacing

Ưu tiên hệ 4/8px:

- 4, 8, 12, 16, 20, 24, 32, 40...

Không dùng spacing ngẫu nhiên nếu không có lý do rõ ràng.

### 4.3. Typography

- Font duy nhất: **Be Vietnam Pro** (weights: 300/400/500/600/700/800)
- ❌ Không thêm font mới cho bất kỳ module nào

### 4.4. Radius / Shadow

- Radius nên theo chuẩn hiện có (8/10/12px)
- Shadow nhẹ, đồng nhất (không mỗi màn một kiểu)

---

## 5) Component rules

### 5.1. Reusable trước, custom sau

Các thành phần lặp lại phải chuẩn hóa và tái sử dụng:

- Button (`.btn-*`)
- Table (`.premium-table`, wrapper)
- Card
- Input/Search/Filter
- Badge
- Pagination

### 5.2. Naming convention

Ưu tiên tên class có nghĩa, theo ngữ cảnh module:

- `.user-controls-row`, `.digital-kpis`, `.view-header-profile`

Tránh:

- `.abc123`, `.box1`, `.tmp`, `.new-div`

### 5.3. Tránh conflict CSS

- Class module-specific cần prefix theo module/ngữ cảnh
- Không override global một cách vô tình
- Không dùng selector quá rộng kiểu `div div div` hoặc `*` để fix nhanh

---

## 6) HTML/CSS/JS quality

### 6.1. HTML

- Dùng semantic: `main`, `section`, `table`, `thead`, `tbody`, ...
- Ảnh phải có `alt`
- Tránh lạm dụng `div` nếu có tag semantic phù hợp

### 6.2. CSS

- ❌ Không inline style trong HTML
- ❌ Không `!important` tràn lan (chỉ dùng khi thật cần)
- ✅ Ưu tiên Flex/Grid cho layout
- ✅ Có responsive breakpoints rõ ràng

### 6.3. JS

- Mỗi module có file JS riêng (`user.js`, `digital.js`, ...)
- Không import script thừa/không dùng
- Không để `console.log` debug ở bản hoàn thiện
- Với modal/toast, dùng API UI chung (`UI.showModal`, `UI.showToast`) để đồng bộ

---

## 7) Responsive (BẮT BUỘC)

Phải hoạt động ổn trên:

- Desktop (>=1280)
- Tablet (~768-1279)
- Mobile (<768)

Yêu cầu tối thiểu:

- Bảng rộng phải có xử lý cuộn ngang hợp lý
- Header controls xuống hàng đúng logic
- Nút thao tác không vỡ layout
- Sidebar hoạt động đúng cơ chế mobile/collapse của layout chung

---

## 8) Accessibility cơ bản

- Tương phản chữ/nền đủ đọc
- Nút/icon-only button cần có `aria-label` khi cần
- Focus state rõ cho input/button
- Form cần label rõ nghĩa

---

## 9) Performance cơ bản

- Ảnh dùng kích thước hợp lý, ưu tiên tối ưu dung lượng
- Tránh import thư viện không cần thiết
- Không tạo CSS/JS trùng lặp giữa module

---

## 10) Cleanup rules

Mỗi lần hoàn thành task phải dọn:

- CSS không dùng
- JS không dùng
- Import trùng/thừa
- Inline style còn sót
- Class name tạm/debug

Không để:

- Dead code
- File rác
- TODO tạm mà không có issue theo dõi

---

## 11) Definition of Done (DoD)

Một page chỉ được xem là hoàn thành khi:

- [ ] Dùng đúng layout chung (inject sidebar/header)
- [ ] UI nhất quán với design system
- [ ] Không lỗi console/lint
- [ ] Không inline style
- [ ] Responsive ổn ở desktop/tablet/mobile
- [ ] Không còn code dư thừa
- [ ] Điều hướng giữa list/view/edit/add hoạt động

---

## 12) Quy trình khi thêm màn mới

1. Tạo file theo naming chuẩn (`module*.html/css/js`)
2. Gắn layout chung + global.css
3. Dựng UI theo component/tokens hiện có
4. Tối ưu responsive
5. Dọn code + kiểm tra lint
6. Tự check theo DoD

---

## 13) Anti-patterns (cần tránh)

- Fix nhanh bằng inline style
- Copy nguyên block CSS giữa module mà không refactor
- Chỉnh global để vá một màn đơn lẻ
- Hardcode spacing/font lệch toàn hệ
- Trộn logic nhiều module vào 1 file JS

---

## Nguyên tắc cốt lõi

> "Không fix riêng từng màn. Luôn nghĩ theo hệ thống."

Mọi thay đổi phải đảm bảo:

- Không phá layout chung
- Không lệch design system
- Không tạo inconsistency giữa các module
