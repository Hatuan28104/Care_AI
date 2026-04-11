const Layout = {
    init: async function () {
        document.body.classList.add('layout-loading');
        try {
            const response = await fetch('../../layout/layout.html');
            if (!response.ok) throw new Error('Không thể tải file layout.html');
            const data = await response.text();

            const parser = new DOMParser();
            const doc = parser.parseFromString(data, 'text/html');

            this.renderSidebar(doc);
            this.renderHeader(doc);
            this.setActiveLinks();
            this.bindEvents();

            if (window.lucide) {
                window.lucide.createIcons();
            }
        } catch (error) {
            console.error('Error fetching layout:', error);
        } finally {
            document.body.classList.remove('layout-loading');
        }
    },

    renderSidebar: function (doc) {
        const sidebarTarget = document.getElementById('sidebar-target');
        const sidebarSource = doc.getElementById('layout-sidebar-source');
        if (sidebarTarget && sidebarSource) {
            sidebarTarget.innerHTML = sidebarSource.innerHTML;
        }
    },

    renderHeader: function (doc) {
        const headerTarget = document.getElementById('header-target');
        const headerSource = doc.getElementById('layout-header-source');
        if (headerTarget && headerSource) {
            headerTarget.innerHTML = headerSource.innerHTML;
        }
    },

    setActiveLinks: function () {
        const path = window.location.pathname.toLowerCase();

        // Helper to check if current page belongs to a module
        const checkModule = (moduleName) => {
            return path.includes(`/${moduleName}/`) ||
                path.includes(`/${moduleName}.html`) ||
                path.includes(`/${moduleName}-`);
        };

        // Sidebar active detection
        document.querySelectorAll('.sidebar__item').forEach(item => {
            const module = item.getAttribute('data-page');
            if (checkModule(module)) {
                item.classList.add('sidebar__item--active');
            } else {
                item.classList.remove('sidebar__item--active');
            }
        });

        // Header tab active detection
        document.querySelectorAll('.header__tab').forEach(tab => {
            const module = tab.getAttribute('data-tab');
            if (checkModule(module)) {
                tab.classList.add('header__tab--active');
            } else {
                tab.classList.remove('header__tab--active');
            }
        });
    },

    bindEvents: function () {
        const btnLogout = document.getElementById('btnLogoutAction');
        if (btnLogout) {
            btnLogout.addEventListener('click', () => {
                if (window.UI) {
                    UI.showModal({
                        type: 'danger',
                        title: 'Đăng xuất?',
                        message: 'Bạn có chắc chắn muốn đăng xuất khỏi hệ thống?',
                        confirmText: 'Xác nhận',
                        cancelText: 'Hủy',
                        onConfirm: () => {
                            window.location.href = '../auth/auth.html';
                        }
                    });
                } else {
                    // Fallback nếu UI chưa init
                    window.location.href = 'pages/auth/auth.html';
                }
            });
        }
    }
};

document.addEventListener('DOMContentLoaded', () => {
    Layout.init();

    document.addEventListener('click', (e) => {
        if (!e.target.closest('.header__action-wrapper') && !e.target.closest('.notif-dropdown')) {
            document.querySelectorAll('.notif-dropdown').forEach(d => d.classList.remove('show'));
        }

        // Close sidebar overlay on overlay click
        if (e.target.id === 'sidebar-overlay' || e.target.classList.contains('sidebar-overlay')) {
            closeSidebar();
        }
    });

    document.body.addEventListener('click', (e) => {
        const toggleBtn = e.target.closest('#sidebarToggle');
        if (toggleBtn) {
            const sidebar = document.getElementById('sidebar');
            const overlay = document.querySelector('.sidebar-overlay');
            const icon = toggleBtn.querySelector('i');
            if (sidebar) {
                const isOpen = sidebar.classList.toggle('sidebar--active');
                if (overlay) overlay.classList.toggle('active', isOpen);
                if (icon) {
                    icon.setAttribute('data-lucide', isOpen ? 'x' : 'menu');
                    if (window.lucide) window.lucide.createIcons();
                }
            }
        }
    });

    function closeSidebar() {
        const sidebar = document.getElementById('sidebar');
        const overlay = document.querySelector('.sidebar-overlay');
        const icon = document.querySelector('#sidebarToggle i');
        if (sidebar) sidebar.classList.remove('sidebar--active');
        if (overlay) overlay.classList.remove('active');
        if (icon) {
            icon.setAttribute('data-lucide', 'menu');
            if (window.lucide) window.lucide.createIcons();
        }
    }
});
