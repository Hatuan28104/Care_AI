const API_BASE = 'https://careai-production.up.railway.app';

function t(key) {
    return window.I18n?.t(key) || key;
}

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
            if (window.I18n && typeof window.I18n.translatePage === 'function') {
                window.I18n.translatePage(navTarget);
            }
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

        document.querySelectorAll('.setting-nav__item').forEach((item) => {
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

    const forms = document.querySelectorAll('.setting-form-v2, form');
    forms.forEach((form) => {
        form.addEventListener('submit', async (e) => {
            e.preventDefault();

            const oldPass = document.getElementById('old-password');
            const newPass = document.getElementById('new-password');
            const confirmPass = document.getElementById('confirm-password');

            if (oldPass && newPass && confirmPass) {
                if (newPass.value !== confirmPass.value) {
                    UI.showToast(t('Mật khẩu mới không khớp!'), 'danger');
                    return;
                }

                if (!oldPass.value || !newPass.value) {
                    UI.showToast(t('Vui lòng điền đầy đủ các trường mật khẩu'), 'warning');
                    return;
                }

                UI.showModal({
                    type: 'confirm-save',
                    title: t('Xác nhận đổi mật khẩu'),
                    message: t('Bạn có chắc chắn muốn thay đổi mật khẩu không?'),
                    confirmText: t('Xác nhận'),
                    cancelText: t('Hủy'),
                    onConfirm: async () => {
                        try {
                            const res = await fetch(`${API_BASE}/auth/admin/change-password`, {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json',
                                    Authorization: `Bearer ${localStorage.getItem('token')}`
                                },
                                body: JSON.stringify({
                                    oldPassword: oldPass.value,
                                    newPassword: newPass.value
                                })
                            });

                            const data = await res.json();
                            if (data.success) {
                                UI.showToast(t('Đổi mật khẩu thành công!'), 'success');
                                oldPass.value = '';
                                newPass.value = '';
                                confirmPass.value = '';
                            } else {
                                UI.showToast(data.message || t('Có lỗi xảy ra'), 'danger');
                            }
                        } catch (err) {
                            UI.showToast(t('Không thể kết nối đến server'), 'danger');
                        }
                    }
                });
            } else {
                UI.showModal({
                    type: 'confirm-save',
                    title: t('Xác nhận lưu thay đổi'),
                    message: t('Bạn có chắc chắn muốn cập nhật thông tin không?'),
                    confirmText: t('Xác nhận'),
                    cancelText: t('Hủy'),
                    onConfirm: () => UI.showToast(t('Cài đặt đã được cập nhật thành công!'))
                });
            }
        });
    });

    const saveConfigBtn = document.querySelector('.btn-save-config');
    if (saveConfigBtn) {
        saveConfigBtn.addEventListener('click', () => {
            UI.showToast(t('Cấu hình thông báo đã được lưu!'));
        });
    }

    const cancelBtn = document.querySelector('.btn-cancel');
    if (cancelBtn) {
        cancelBtn.addEventListener('click', () => {
            UI.showToast(t('Đã hủy thay đổi.'), 'warning');
        });
    }

    const adminPhoneInput = document.getElementById('admin-phone');
    if (adminPhoneInput) {
        const savedPhone = localStorage.getItem('user_phone');
        if (savedPhone) adminPhoneInput.value = savedPhone;
    }

    const langSelect = document.getElementById('language-select');
    if (langSelect) {
        const currentLang = window.I18n && window.I18n.getCurrentLang ? window.I18n.getCurrentLang() : 'vi';
        langSelect.value = localStorage.getItem('care_ai_lang') || currentLang;
        langSelect.addEventListener('change', (e) => {
            const selected = e.target.value;
            localStorage.setItem('care_ai_lang', selected);
            if (window.I18n && window.I18n.setLanguage) {
                window.I18n.setLanguage(selected);
            }
            const optionLabel = e.target.options[e.target.selectedIndex]?.text || selected;
            UI.showToast(`${t('Đã đổi ngôn ngữ sang ')}${optionLabel}`);
        });
    }

    const themeBtns = document.querySelectorAll('[data-theme-btn]');
    if (themeBtns.length > 0) {
        const currentTheme = localStorage.getItem('care_ai_theme') || 'light';
        themeBtns.forEach((btn) => {
            if (btn.getAttribute('data-theme-btn') === currentTheme) {
                btn.classList.add('active');
            }
            btn.addEventListener('click', () => {
                const theme = btn.getAttribute('data-theme-btn');
                localStorage.setItem('care_ai_theme', theme);
                document.documentElement.setAttribute('data-theme', theme);
                themeBtns.forEach((b) => b.classList.remove('active'));
                btn.classList.add('active');
                UI.showToast(`${t('Đã chuyển sang giao diện ')}${theme === 'dark' ? t('Tối') : t('Sáng')}`);
            });
        });
    }
});
