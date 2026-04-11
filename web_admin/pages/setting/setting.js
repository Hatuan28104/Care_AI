// Settings logic
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
        form.addEventListener('submit', (e) => {
            e.preventDefault();
            if (window.UI) {
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
});
