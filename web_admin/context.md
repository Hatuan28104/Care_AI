# Care AI Web Admin
> Project: **web_admin** (dashboard quản trị)
> Tech: **Vanilla HTML/CSS/JS** + CDN libs (Lucide, Chart.js, Litepicker)
> Backend API base: `https://careai-production.up.railway.app`

---

## 1. Folder structure (actual)

web_admin/
├── index.html
├── context.md
│
├── assets/
│   ├── css/
│   │   ├── global.css
│   │   ├── ui.css
│   │   └── layout.css
│   └── js/
│       ├── main.js
│       └── ui.js
│
├── layout/
│   ├── layout.html
│   └── layout.js
│
└── pages/
    ├── auth/
    │   ├── auth.html
    │   ├── auth.css
    │   └── auth.js
    ├── dashboard/
    │   ├── dashboard.html
    │   ├── dashboard.css
    │   └── dashboard.js
    ├── user/
    │   ├── user.html
    │   ├── user.js
    │   ├── user.css
    │   ├── user-view.html
    │   ├── user-view.css
    │   ├── user-edit.html
    │   └── user-edit.css
    ├── digital/
    │   ├── digital.html
    │   ├── digital.js
    │   ├── digital.css
    │   ├── digital-view.html
    │   ├── digital-view.css
    │   ├── digital-add.html
    │   ├── digital-add.css
    │   ├── digital-edit.html
    │   └── digital-edit.css
    └── setting/
        ├── setting.html
        ├── setting.css
        ├── setting-profile.css
        ├── setting-system.html
        ├── setting-system.css
        ├── setting-logs.html
        ├── setting-logs.css
        ├── setting-notifications.html
        ├── setting-notifications.css
        ├── setting-nav.html
        └── setting.js

---

## 2. Core architecture

### Entry
- `index.html`: entry point, điều hướng vào trang auth.

### Shared UI
- `assets/css/global.css`: variables, reset, base styles.
- `assets/css/ui.css`: reusable components (table, button, modal/toast classes).
- `assets/css/layout.css`: sidebar/header styles.
- `assets/js/ui.js`: UI helpers (toast/modal/panel/dropdown).
- `assets/js/main.js`: global utilities/navigation behaviors.

### Layout injection
- `layout/layout.html`: sidebar + header template.
- `layout/layout.js`: inject layout vào các trang (trừ auth), set active menu, bind events.

### Feature modules
- `pages/auth`: login admin.
- `pages/dashboard`: charts + KPI + alerts.
- `pages/user`: user list/view/edit.
- `pages/digital`: digital human list/view/add/edit.
- `pages/setting`: profile/system/logs/notifications + setting nav.

---

## 3. Auth flow (current)

File: `pages/auth/auth.js`

- API: `POST /auth/admin/login`
- Payload:
```json
{
  "sodienthoai": "...",
  "matkhau": "..."
}
```
- Success:
  - save `localStorage.token`
  - save `localStorage.user_phone`
  - redirect `../dashboard/dashboard.html`
- Error: hiển thị tại `#loginError`.

---

## 4. Main API usage (current)

- Auth: `/auth/admin/login`
- Dashboard: `/profile/dashboard/users`, `/api/chat/conversations`, `/notification/admin/alerts`
- Users: `/profile`
- Digital Human: `/api/digital-human`

> Most pages are API-driven with client-side rendering and simple error handling.

---

## 5. UI/UX conventions

- All feature pages (except auth) should use shared layout injection.
- Prefer shared UI helpers in `assets/js/ui.js` for modal/toast.
- Keep CSS split: global + layout + module-specific files.

---

## 6. Current state summary

- Structure is clear for small/medium admin panel.
- No frontend framework; maintenance relies on naming discipline and shared helpers.
- Suitable for current project size, but avoid duplicating modal/toast/table logic across modules.
