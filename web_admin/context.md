# Care AI — Project Context

> Tên project: **Care AI** | Dashboard quản trị cho ứng dụng chăm sóc sức khỏe AI  
> Stack: Vanilla HTML / CSS / JavaScript (không dùng framework)  
> Icon: [Lucide Icons](https://lucide.dev/) (CDN)  
> Font: **Be Vietnam Pro** 

---

## Cấu trúc thư mục (Tree)

```
web_admin/
├── index.html                   ← Entry point (redirect tự động)
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
- Import: `global.css`, `auth.css`, `lucide CDN`, `main.js`, `ui.js`, `auth.js`.
- Form fields:
  - **Số điện thoại** (id: `sdt`, placeholder: `03xxxxxxxx`)
  - **Mật khẩu** (id: `password`, toggle show/hide bằng `togglePassword()`)
- Demo account: `09xxxxxxxx / admin123`
- Error display: span `#loginError` với inline style

### `auth.js`
- **API Endpoint**: `POST ${API_BASE}/auth/admin/login` (prod: `careai-production.up.railway.app`)
- `togglePassword()` — đổi type input + icon lucide `eye`/`eye-off`.
- `login()` — validate **số điện thoại** + password:
  - Body: `{ sodienthoai: phone, matkhau: password }`
  - Success: lưu `localStorage.setItem("token", data.token)` + `localStorage.setItem("user_phone", phone)` → redirect `dashboard.html`
  - Failure: hiển thị error message từ API
- **Demo account**: `09xxxxxxxx / admin123` (số điện thoại format)

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
- **API Endpoints**:
  - `GET ${API_BASE}/profile/dashboard/users` — dữ liệu người dùng
  - `GET ${API_BASE}/api/chat/conversations` — dữ liệu tương tác
  - `GET ${API_BASE}/notification/admin/alerts` — dữ liệu cảnh báo
- `initCharts()` — khởi tạo 2 chart rỗng bằng Chart.js với config màu sắc, grid style.
- `groupByDate(data, dateField, valueField)` — nhóm dữ liệu từ API theo ngày, hỗ trợ filter date range.
- `toChartSeries(map)` — chuyển đổi dữ liệu thành labels và values cho chart.
- **Litepicker**: date range picker (CDN), mặc định chọn 7 ngày gần nhất. Khi chọn range mới → fetch API với filter date → render chart thực.
- Alert table: dữ liệu từ API endpoint `/notification/admin/alerts`.

---

## Module: `pages/user/`

### `user.html`
- Danh sách người dùng với search + paginate.
- Table columns: Họ tên/Email, Giới tính (badge), Số điện thoại, Ngày tạo, Actions (view/edit/delete).

### `user-view.html` / `user-edit.html`
- Static pages xem chi tiết và chỉnh sửa thông tin 1 người dùng.

### `user.js`
- **API**: `GET ${API_BASE}/profile` — fetch danh sách người dùng từ backend.
- `PAGE_SIZE = 10`, phân trang client-side.
- Data mapping:
  - `toAbsoluteImageUrl(path)` — convert relative path → full URL từ API_BASE
  - `mapUserRecord(user)` — map API response field sang UI field (id, name, email, phone, gender, created_date, avatar)
  - `normalizeGenderValue(value)` — chuẩn hóa giá trị giới tính (0, 1, 2)
- `renderTable()` — render tbody từ `filteredUsers` (hay toàn bộ `users` nếu chưa search) + gọi `renderPagination()` + `updateCount()`.
- `renderPagination()` — render nút prev/next và số trang (ẩn giữa nếu > 6 trang).
- `confirmDelete(name, idx)` — call `confirmModal()` (uses `UI.showModal()` if available, fallback `confirm()`) → xóa khỏi mảng → re-render → toast.
- `initSearch()` — lắng nghe input trong `.search-field-shared input`, lọc theo tên/email/điện thoại.
- Fallback: nếu `UI` không có, dùng `alert()` / `confirm()` mặc định.

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
- **API**: `GET ${API_BASE}/api/digital-human` — fetch danh sách nhân vật số từ backend.
- `DIGITAL_PAGE_SIZE = 10`. Logic tương tự `user.js`.
- Data mapping:
  - `toAbsoluteImageUrl(path)` — convert relative → full URL
  - `toStoredImagePath(urlOrPath)` — convert full URL → relative path khi lưu
  - Map API fields: `digitalhuman_id`, `tendigitalhuman`, `nghenghiep`, `gioitinh`, `imageurl`
- `showToastMessage(message)` — gọi `UI.showToast()` nếu có, fallback `alert()`
- `confirmModal({ title, message, type, onConfirm })` — gọi `UI.showModal()` nếu có, fallback `confirm()`
- `confirmAddChar()` — modal xác nhận → POST API → toast → redirect `digital.html`.
- `confirmEditChar()` — modal xác nhận lưu → PUT API → toast → redirect.
- `confirmDeleteChar(name, idx)` — modal xóa (type: 'danger') → DELETE API → toast → redirect.
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
- Form chỉnh sửa admin:
  - **Số điện thoại** (id: `admin-phone`, readonly hoặc display only)
  - **Thay đổi mật khẩu** (3 input: `old-password`, `new-password`, `confirm-password`)
  - Buttons: "Hủy thay đổi" (class: `btn-pill btn-pill--secondary`), "Cập nhật danh tính" (class: `btn-pill btn-pill--primary`)
- **Không có** form tên, email, ảnh đại diện
- CSS riêng: `setting.css` + `setting-profile.css`

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

| Module | Dữ liệu | API Endpoint | Notes |
|--------|---------|--------------|-------|
| Dashboard KPIs | 4 thẻ stats | Hardcoded HTML | Cập nhật bên ngoài |
| Dashboard Charts | User growth, Interaction | `/profile/dashboard/users`, `/api/chat/conversations` | Fetch từ API, filter theo date range |
| Dashboard Alerts | Bảng cảnh báo | `/notification/admin/alerts` | Fetch từ API |
| Users List | Danh sách người dùng | `/profile` | Fetch từ API, PAGE_SIZE = 10 |
| Characters List | Danh sách nhân vật số | `/api/digital-human` | Fetch từ API, DIGITAL_PAGE_SIZE = 10 |
| Auth | Login endpoint | `/auth/admin/login` | POST { sodienthoai, matkhau } |
| Notifications (header) | Dropdown thông báo | Hardcoded HTML | Cập nhật bên ngoài |
| All Activities Panel | Activities history | Hardcoded JS | ui.js (`openAllActivitiesPanel`) |
| All Alerts Panel | Alerts panel | Hardcoded JS | ui.js (`openAllAlertsPanel`) |

> ✅ **API Backend đang hoạt động** — base URL: `${API_BASE} = 'https://careai-production.up.railway.app'`

---

## Third-party Libraries

| Thư viện | Phiên bản | Dùng ở đâu | CDN |
|----------|-----------|------------|-----|
| Lucide Icons | latest | Mọi trang | `https://unpkg.com/lucide@latest` |
| Chart.js | latest | dashboard | `cdn.jsdelivr.net/npm/chart.js` |
| Litepicker | latest | dashboard | `cdn.jsdelivr.net/npm/litepicker` |

---

## Quy tắc dự án (Guidelines)

1. **Không duplicate** Sidebar/Header — luôn inject qua `layout.js`.
2. **Inline style**: Hiện tại vẫn có ở một số trang (ví dụ `dashboard.html:143`). Khuyến cáo dùng class từ `ui.css` hoặc CSS module riêng.
3. **UI Feedback**: Nên dùng `UI.showModal()` + `UI.showToast()` khi có. Hiện tại có fallback `alert/confirm` ở `user.js:135`, `digital.js:42`.
4. **CSS modules**: Mỗi trang có file riêng, luôn import `global.css` + `ui.css` + `layout.css` (trừ auth.html).
5. **Naming convention**: `module.html` → `module-view.html` → `module-edit.html` → `module-add.html`.
6. **Responsive**: Desktop (≥1280) / Tablet (~768–1279) / Mobile (<768).
7. **API Integration**: Modules (auth, dashboard, user, digital, setting) đều kết nối backend qua fetch API với error handling.
