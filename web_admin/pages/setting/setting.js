// Settings logic
const API_BASE = 'https://careai-production.up.railway.app';
const SettingNav = {
    init: async function () {
        document.body.classList.add('setting-nav-loading');

        try {
            const response = await fetch('./setting-nav.html');
            if (!response.ok) throw new Error('Không thể tải setting-nav.html');
            const data = await response.text();

            const parser = new DOMParser();
            const doc = parser.parseFromString(data, 'text/html');

            this.renderNav(doc);
            this.setActiveLink();

            if (window.lucide) {
                window.lucide.createIcons();
            }
        } catch (error) {
            console.error('Error loading setting nav:', error);
        } finally {
            document.body.classList.remove('setting-nav-loading');
        }
    },

    renderNav: function (doc) {
        const navTarget = document.getElementById('setting-nav-target');
        const navSource = doc.getElementById('setting-nav-source');

        if (navTarget && navSource) {
            navTarget.innerHTML = navSource.innerHTML;
        }
    },

    setActiveLink: function () {
        const path = window.location.pathname.toLowerCase();
        let current = 'profile';

        if (path.includes('setting-system')) {
            current = 'system';
        } else if (path.includes('setting-logs')) {
            current = 'logs';
        } else if (path.includes('setting-notifications')) {
            current = 'notifications';
        }

        document.querySelectorAll('.setting-nav__item').forEach(item => {
            const page = item.getAttribute('data-setting-page');
            if (page === current) {
                item.classList.add('active');
            } else {
                item.classList.remove('active');
            }
        });
    }
};

document.addEventListener('DOMContentLoaded', async () => {
    await SettingNav.init();

    // Handle settings form submit
    const forms = document.querySelectorAll('.setting-form-v2, form');
    forms.forEach(form => {
        form.addEventListener('submit', async (e) => {
            e.preventDefault();

            // Check if this is the profile form (has password fields)
            const oldPass = document.getElementById('old-password');
            const newPass = document.getElementById('new-password');
            const confirmPass = document.getElementById('confirm-password');

            if (oldPass && newPass && confirmPass) {
                if (newPass.value !== confirmPass.value) {
                    UI.showToast('Mật khẩu mới không khớp!', 'danger');
                    return;
                }

                if (!oldPass.value || !newPass.value) {
                    UI.showToast('Vui lòng điền đầy đủ các trường mật khẩu', 'warning');
                    return;
                }

                UI.showModal({
                    type: 'confirm-save',
                    title: 'Xác nhận đổi mật khẩu',
                    message: 'Bạn có chắc chắn muốn thay đổi mật khẩu không?',
                    confirmText: 'Xác nhận',
                    cancelText: 'Hủy',
                    onConfirm: async () => {
                        try {
                            const res = await fetch(`${API_BASE}/auth/admin/change-password`, {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization': `Bearer ${localStorage.getItem('token')}`
                                },
                                body: JSON.stringify({
                                    oldPassword: oldPass.value,
                                    newPassword: newPass.value
                                })
                            });

                            const data = await res.json();
                            if (data.success) {
                                UI.showToast('Đổi mật khẩu thành công!', 'success');
                                // Clear fields
                                oldPass.value = '';
                                newPass.value = '';
                                confirmPass.value = '';
                            } else {
                                UI.showToast(data.message || 'Có lỗi xảy ra', 'danger');
                            }
                        } catch (err) {
                            UI.showToast('Không thể kết nối đến server', 'danger');
                        }
                    }
                });
            } else {
                // Other forms
                UI.showModal({
                    type: 'confirm-save',
                    title: 'Xác nhận lưu thay đổi',
                    message: 'Bạn có chắc chắn muốn cập nhật thông tin không?',
                    confirmText: 'Xác nhận',
                    cancelText: 'Hủy',
                    onConfirm: () => UI.showToast('Cài đặt đã được cập nhật thành công!')
                });
            }
        });
    });

    // Handle "Lưu cấu hình" button (notifications page)
    const saveConfigBtn = document.querySelector('.btn-save-config');
    if (saveConfigBtn) {
        saveConfigBtn.addEventListener('click', () => {
            UI.showToast('Cấu hình thông báo đã được lưu!');
        });
    }

    // Handle "Hủy bỏ" button
    const cancelBtn = document.querySelector('.btn-cancel');
    if (cancelBtn) {
        cancelBtn.addEventListener('click', () => {
            UI.showToast('Đã hủy thay đổi.', 'warning');
        });
    }

    // Populate profile phone
    const adminPhoneInput = document.getElementById('admin-phone');
    if (adminPhoneInput) {
        const savedPhone = localStorage.getItem('user_phone');
        if (savedPhone) adminPhoneInput.value = savedPhone;
    }

    // Handle system settings (language & theme)
    const langSelect = document.getElementById('language-select');
    if (langSelect) {
        langSelect.value = localStorage.getItem('care_ai_lang') || 'Tiếng việt';
        langSelect.addEventListener('change', (e) => {
            localStorage.setItem('care_ai_lang', e.target.value);
            UI.showToast('Đã đổi ngôn ngữ sang ' + e.target.value);
        });
    }

    const themeBtns = document.querySelectorAll('[data-theme-btn]');
    if (themeBtns.length > 0) {
        const currentTheme = localStorage.getItem('care_ai_theme') || 'light';
        themeBtns.forEach(btn => {
            if (btn.getAttribute('data-theme-btn') === currentTheme) {
                btn.classList.add('active');
            }
            btn.addEventListener('click', () => {
                const theme = btn.getAttribute('data-theme-btn');
                localStorage.setItem('care_ai_theme', theme);
                document.documentElement.setAttribute('data-theme', theme);
                themeBtns.forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                UI.showToast('Đã chuyển sang giao diện ' + (theme === 'dark' ? 'Tối' : 'Sáng'));
            });
        });
    }
});
