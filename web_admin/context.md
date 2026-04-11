# Care AI — Project Context

> Tên project: **Care AI** | Dashboard quản trị cho ứng dụng chăm sóc sức khỏe AI  
> Stack: Vanilla HTML / CSS / JavaScript (không dùng framework)  
> Icon: [Lucide Icons](https://lucide.dev/) (CDN)  
> Font: **Be Vietnam Pro** 

---

## Cấu trúc thư mục (Tree)

```
AG/
├── index.html                   ← Entry point (redirect tự động)
├── rules.md                     ← Quy tắc coding bắt buộc
├── context.md                   ← File này
│
├── assets/
│   ├── css/
│   │   ├── global.css           ← CSS Variables + Reset + Layout grid
│   │   ├── ui.css               ← Design System (components dùng chung)
│   │   └── layout.css           ← Style cho Sidebar + Header
│   ├── js/
│   │   ├── main.js              ← Utils toàn cục (navigation feedback)
│   │   └── ui.js                ← UI API (Modal, Toast, Panel, Dropdown)
│   └── images/
│       └── logo.png             ← Logo Care AI
│
├── layout/
│   ├── layout.html              ← Template HTML Sidebar + Header
│   └── layout.js               ← Script inject layout vào các trang
│
└── pages/
    ├── auth/                    ← Module đăng nhập
    │   ├── auth.html
    │   ├── auth.css
    │   └── auth.js
    ├── dashboard/               ← Module tổng quan
    │   ├── dashboard.html
    │   ├── dashboard.css
    │   └── dashboard.js
    ├── user/                    ← Module quản lý người dùng
    │   ├── user.html
    │   ├── user-view.html
    │   ├── user-edit.html
    │   └── user.css / user.js
    ├── digital/                 ← Module quản lý nhân vật số (Digital Physician)
    │   ├── digital.html
    │   ├── digital-view.html
    │   ├── digital-add.html
    │   ├── digital-edit.html
    │   ├── digital.css / digital-view.css / digital-add.css / digital-edit.css
    │   └── digital.js
    └── setting/                 ← Module cài đặt
        ├── setting.html         ← Hồ sơ Admin (trang mặc định)
        ├── setting-system.html  ← Cài đặt hệ thống
        ├── setting-logs.html    ← Nhật ký bảo mật
        ├── setting-notifications.html ← Quy tắc thông báo
        ├── setting-nav.html     ← Template nav nội bộ của Setting
        ├── setting.css / setting-profile.css / setting-system.css
        ├── setting-logs.css / setting-notifications.css
        └── setting.js
```

---

## Chi tiết từng file

### `index.html`
- **Mục đích**: Entry point duy nhất của app.
- **Xử lý**: Hiển thị loading spinner → sau 500ms tự redirect sang `pages/auth/auth.html`.
- **Không có logic**: Chỉ là cổng vào, chưa kiểm tra auth token.

---

### `assets/css/global.css`
- **Mục đích**: Nền tảng CSS của toàn bộ project.
- **Nội dung cụ thể**:
  - CSS Variables dùng toàn cục: màu, spacing, radius, shadow, transition.
  - Reset style (`*`, `body`, `a`, `ul`, `button`, `input`).
  - Font family mặc định: `Be Vietnam Pro`.
  - Class layout lõi: `.dashboard-layout` (flex), `.dashboard-content` (flex-col), `.main-body` (padding 24px, max-width 1600px).
  - Animation `.animate-fade-in` (fadeIn từ translateY 10px).
- **Biến quan trọng**:
  ```css
  --primary-blue: #1877F2
  --bg-main: #F6F6F6
  --bg-card: #FFFFFF
  --text-primary: #0B1C30
  --text-secondary: #64748B
  --status-success / danger / warning / info
  --shadow-sm / md / lg / premium
  --radius-sm: 8px | --radius-md: 12px | --radius-lg: 20px
  --space-1: 8px ... --space-10: 64px
  ```

---

### `assets/css/ui.css`
- **Mục đích**: Design system component library. Đây là file CSS quan trọng nhất sau global.css.
- **Components** (644 dòng, chia 5 section):
  1. **Page Header** — `.page-header`, `.page-title`, `.page-subtitle`
  2. **Data Tables** — `.premium-table-wrapper`, `.premium-table`, `.table-controls-row`, `.search-field-shared`, `.pagination-row`, `.pagination-controls`, `.page-link`
  3. **Buttons** — `.btn`, `.btn--primary`, `.btn--secondary`, `.btn--danger`, `.btn--large`
  4. **Overlays (Modal & Panel)** — `.modal-overlay`, `.modal-card`, `.modal--success/danger`, `.btn-modal-*`, `.modal-card--panel` (fullscreen panel), `.panel-modal__header/body`
  5. **Notifications** — `.notif-dropdown`, `.notif-timeline`, `.notif-item`, `.notif-dot`, `.toast-container`, `.toast-item`
- **Lưu ý**: Mọi trang trong `pages/` đều import file này, không được tạo component duplicate.

---

### `assets/css/layout.css`
- **Mục đích**: Style cho Sidebar và Header được inject vào mọi trang.
- **Covers**: `.sidebar`, `.sidebar__brand`, `.sidebar__nav`, `.sidebar__item`, `.sidebar__item--active`, `.sidebar__link`, `.sidebar__footer`, `.btn-logout`, `.header`, `.header__tabs`, `.header__tab--active`, `.header__actions`, `.notif-dropdown`, `.header__profile`.

---

### `assets/js/ui.js`
- **Mục đích**: Bộ UI API dùng chung. Export object `window.UI`.
- **Các hàm**:
  - `UI.showModal({ type, title, message, confirmText, cancelText, onConfirm, extraClass })` — hiển thị hộp thoại xác nhận. `type: 'danger'/'success'` quyết định màu icon và nút.
  - `UI.showToast(message)` — hiển thị thông báo nhỏ góc trên phải, tự biến mất sau 3s.
  - `UI.showPanel({ title, bodyHtml, extraClass })` — mở panel fullscreen.
  - `UI.openAllActivitiesPanel()` — panel danh sách hoạt động gần đây (hardcoded data).
  - `UI.openAllAlertsPanel()` — panel bảng cảnh báo bất thường (hardcoded data).
  - `UI.toggleDropdown(id)` — toggle show/hide dropdown theo ID.
- **Khởi động**: Gọi `initNavigationFeedback()` từ `main.js` khi DOMContentLoaded.

---

### `assets/js/main.js`
- **Mục đích**: Chứa hàm utility `initNavigationFeedback()`.
- **Xử lý**: Dùng `MutationObserver` để chờ sidebar được inject xong, sau đó gắn class `.is-navigating` vào link sidebar khi click → tạo hiệu ứng phản hồi khi chuyển trang.

---

### `layout/layout.html`
- **Mục đích**: Template HTML duy nhất cho Sidebar và Header, dùng chung cho tất cả trang (trừ auth).
- **Cấu trúc**:
  - `#layout-sidebar-source`: chứa `<aside class="sidebar">` với 4 nav item: Trang chủ, Quản lý người dùng, Quản lý nhân vật số, Cài đặt. Mỗi item có `data-page="..."` để highlight active.
  - `#layout-header-source`: chứa `<header>` với toggle sidebar, nav tabs (Báo cáo, Người dùng, Nhân vật), nút chuông (notification dropdown), avatar admin (click → setting.html).
- **Dữ liệu notifications**: Hardcoded 4 item trong dropdown (cập nhật hồ sơ, bác sĩ xem báo cáo, tối ưu AI, xuất báo cáo).

---

### `layout/layout.js`
- **Mục đích**: Script inject Sidebar + Header vào các trang.
- **Cơ chế**: `Layout.init()` → `fetch('../../layout/layout.html')` → parse → `renderSidebar()` / `renderHeader()` → `setActiveLinks()` → `bindEvents()`.
- **Active link detection**: So sánh `window.location.pathname` với `data-page` / `data-tab` attribute. Hỗ trợ detect module theo path (`/dashboard/`, `/user-view.html`, `/user-`...).
- **Sự kiện** (`bindEvents`):
  - Nút **ĐĂNG XUẤT** → gọi `UI.showModal()` xác nhận → redirect `auth.html`.
  - Nút **toggle sidebar** (mobile) → toggle class `sidebar--active` và overlay.
  - Click **sidebar-overlay** → đóng sidebar.

---

## Module: `pages/auth/`

### `auth.html`
- Trang đăng nhập — **không dùng layout chung** (không có sidebar/header).
- Import: `global.css`, `auth.css`, `lucide`, `main.js`, `ui.js`, `auth.js`.
- UI: Logo + form email/password với nút toggle show/hide password.
- Demo account hiển thị luôn: `admin@example.com / admin123`.

### `auth.js`
- `togglePassword()` — đổi type input + icon lucide `eye`/`eye-off`.
- `login()` — validate email + password. Nếu đúng: `localStorage.setItem('loggedIn', 'true')` → sau 1.2s redirect `dashboard.html`. Nếu sai: hiển thị lỗi inline.
- **Lưu ý**: Chưa có real auth, check cứng `admin@example.com / admin123`.

---

## Module: `pages/dashboard/`

### `dashboard.html`
- Trang tổng quan. Import thêm: `chart.js` (CDN), `litepicker` (CDN).
- **Sections**:
  - **Page header**: tiêu đề + date range picker (`Litepicker`) + nút Xuất báo cáo.
  - **KPI Grid** (4 thẻ): Tổng người dùng (4218), Người dùng mới (342), Lượt tương tác (8412), Thời gian TB (4m 32s).
  - **Charts** (2 biểu đồ): Tăng trưởng người dùng (line chart `userGrowthChart`) + Tương tác (bar chart `interactionChart`).
  - **Alerts table**: Bảng cảnh báo bất thường (4 row hardcoded) + nút "Xem tất cả" → `UI.openAllAlertsPanel()`.

### `dashboard.js`
- `initCharts()` — khởi tạo 2 chart rỗng bằng Chart.js với config màu sắc, grid style.
- `updateChartsWithDateRange(startDate, endDate)` — tính số ngày chênh lệch → generate labels (theo giờ / ngày / tuần / tháng) → generate mock data ngẫu nhiên → update cả 2 chart.
- `Litepicker` — date range picker, mặc định chọn 7 ngày gần nhất, khi chọn range mới thì gọi `updateChartsWithDateRange`.
- Nút **Xuất báo cáo**: `UI.showModal()` xác nhận → `UI.showToast()`.

---

## Module: `pages/user/`

### `user.html`
- Danh sách người dùng với search + paginate.
- Table columns: Họ tên/Email, Giới tính (badge), Số điện thoại, Ngày tạo, Actions (view/edit/delete).

### `user-view.html` / `user-edit.html`
- Static pages xem chi tiết và chỉnh sửa thông tin 1 người dùng.

### `user.js`
- Data: Mảng cố định `USERS` gồm 8 người dùng với avatar từ `ui-avatars.com`.
- `PAGE_SIZE = 5`, phân trang client-side.
- `renderTable()` — render tbody + gọi `renderPagination()` + `updateCount()`.
- `renderPagination()` — render nút prev/next và số trang (ẩn giữa nếu > 6 trang).
- `confirmDelete(name, idx)` — `UI.showModal({ type: 'danger' })` → xóa khỏi mảng → re-render → `UI.showToast()`.
- `initSearch()` — lắng nghe input trong `.search-field-shared input`, lọc theo tên/email/điện thoại.

---

## Module: `pages/digital/`

### `digital.html`
- Danh sách nhân vật số (Digital Physician / AI Characters).
- Table columns: Mã ID (badge), Ảnh/Tên, Nghề nghiệp, Giới tính (badge), Actions.

### `digital-view.html`
- Xem chi tiết 1 nhân vật số.

### `digital-add.html`
- Form thêm mới nhân vật số.

### `digital-edit.html`
- Form chỉnh sửa thông tin nhân vật số.

### `digital.js`
- Data: Mảng `CHARACTERS` gồm 7 nhân vật: LuNa (y tá), Đức Nam (luật sư), Mỹ Huyền, SuLi, Bà Nula, Dr. Hùng (bác sĩ nội khoa), Ms. Tâm. Ảnh từ Unsplash.
- `DIGITAL_PAGE_SIZE = 5`. Logic tương tự `user.js`.
- `confirmAddChar()` — modal xác nhận → toast → redirect `digital.html`.
- `confirmEditChar()` — modal xác nhận lưu → toast → redirect.
- `confirmDeleteChar(name, idx)` — modal xóa → xóa khỏi mảng → toast → redirect.
- `initDigitalSearch()` — lọc theo tên, mã ID, nghề nghiệp.

---

## Module: `pages/setting/`

### Cơ chế hai lớp inject
Setting dùng 2 lớp inject:
1. **Lớp 1**: `layout.js` inject Sidebar + Header chính (giống mọi module khác).
2. **Lớp 2**: `setting.js` inject navigation nội bộ của Setting (`setting-nav.html` → `#setting-nav-target`).

### `setting-nav.html`
- Template nav 4 mục: Hồ sơ Admin (`setting.html`), Cài đặt hệ thống (`setting-system.html`), Nhật ký bảo mật (`setting-logs.html`), Quy tắc thông báo (`setting-notifications.html`).
- Dùng `data-setting-page="profile/system/logs/notifications"` để highlight active.

### `setting.js`
- `SettingNav.init()` — fetch `setting-nav.html` → inject vào `#setting-nav-target`.
- `SettingNav.setActiveLink()` — detect URL, set active class cho nav item tương ứng.
- Form submit handler: bắt mọi `form` và `.setting-form-v2` → hiện `UI.showModal()` xác nhận lưu.
- Nút `.btn-save-config` (notifications page): `UI.showToast('Cấu hình đã lưu')`.
- Nút `.btn-cancel`: `UI.showToast('Đã hủy thay đổi')`.

### `setting.html` (Hồ sơ Admin)
- Form chỉnh sửa thông tin admin: tên, email, ảnh đại diện.
- Form đổi mật khẩu: mật khẩu cũ, mới, xác nhận.
- CSS riêng: `setting.css` + `setting-profile.css`.

### `setting-system.html` (Cài đặt hệ thống)
- Các toggle / input cấu hình hệ thống.
- CSS riêng: `setting-system.css`.

### `setting-logs.html` (Nhật ký bảo mật)
- Bảng ghi lại lịch sử đăng nhập/hoạt động (hardcoded rows).
- CSS riêng: `setting-logs.css`.

### `setting-notifications.html` (Quy tắc thông báo)
- Toggle bật/tắt các loại thông báo, nút "Lưu cấu hình".
- CSS riêng: `setting-notifications.css`.

---

## Luồng dữ liệu & Navigation

```
index.html
  └─ redirect → auth/auth.html
        └─ login thành công → dashboard/dashboard.html
              └─ sidebar (tất cả pages):
                    ├─ Trang chủ       → dashboard/dashboard.html
                    ├─ Người dùng      → user/user.html
                    │     ├─ user-view.html
                    │     └─ user-edit.html
                    ├─ Nhân vật số     → digital/digital.html
                    │     ├─ digital-view.html
                    │     ├─ digital-add.html
                    │     └─ digital-edit.html
                    └─ Cài đặt         → setting/setting.html
                          ├─ setting-system.html
                          ├─ setting-logs.html
                          └─ setting-notifications.html
```

---

## Data & State hiện tại

| Module | Dữ liệu | Nguồn |
|--------|---------|-------|
| Dashboard KPIs | Hardcoded HTML | dashboard.html |
| Dashboard Charts | Mock random | dashboard.js (updateChartsWithDateRange) |
| Dashboard Alerts | Hardcoded HTML + JS | dashboard.html + ui.js |
| Users | Mảng JS 8 phần tử | user.js (`USERS`) |
| Characters | Mảng JS 7 phần tử | digital.js (`CHARACTERS`) |
| Notifications (header) | Hardcoded HTML | layout.html |
| All Activities Panel | Hardcoded JS | ui.js (`openAllActivitiesPanel`) |
| All Alerts Panel | Hardcoded JS | ui.js (`openAllAlertsPanel`) |

> ⚠️ Toàn bộ data hiện tại là **mock/hardcoded** — chưa có API backend thực.

---

## Third-party Libraries

| Thư viện | Phiên bản | Dùng ở đâu | CDN |
|----------|-----------|------------|-----|
| Lucide Icons | latest | Mọi trang | `https://unpkg.com/lucide@latest` |
| Chart.js | latest | dashboard | `cdn.jsdelivr.net/npm/chart.js` |
| Litepicker | latest | dashboard | `cdn.jsdelivr.net/npm/litepicker` |

---

## Quy tắc quan trọng (từ `rules.md`)

1. **Không duplicate** Sidebar/Header — luôn inject qua `layout.js`.
2. **Không inline style** trong HTML — dùng class từ `ui.css` hoặc CSS module riêng.
3. **CRUD UI actions** phải dùng `UI.showModal()` + `UI.showToast()` — không alert/confirm mặc định.
4. **CSS module** mỗi trang có file riêng, luôn import `global.css` + `ui.css` + `layout.css`.
5. **Naming pages**: `module.html` → `module-view.html` → `module-edit.html` → `module-add.html`.
6. **Responsive**: Desktop (≥1280) / Tablet (~768–1279) / Mobile (<768).
