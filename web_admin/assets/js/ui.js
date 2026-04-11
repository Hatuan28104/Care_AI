const UI = {
    initTheme: function () {
        const savedTheme = localStorage.getItem('care_ai_theme') || 'light';
        document.documentElement.setAttribute('data-theme', savedTheme);
    },
    // Modal
    showModal: function ({ type, title, message, confirmText, cancelText, onConfirm, extraClass }) {
        let modalOverlay = document.getElementById('global-modal-overlay');
        let modalCard = document.getElementById('global-modal-card');

        if (!modalOverlay) {
            modalOverlay = document.createElement('div');
            modalOverlay.id = 'global-modal-overlay';
            modalOverlay.className = 'modal-overlay';
            document.body.appendChild(modalOverlay);
        }

        if (!modalCard) {
            modalCard = document.createElement('div');
            modalCard.id = 'global-modal-card';
            modalCard.className = 'modal-card';
            document.body.appendChild(modalCard);
        }

        const isDanger = type === 'danger' || type === 'error' || type === 'warning';
        const isExport = type === 'export';

        modalCard.className = 'modal-card';
        if (isDanger) {
            modalCard.classList.add('modal--danger');
        } else if (isExport) {
            modalCard.classList.add('modal--export');
        } else {
            modalCard.classList.add('modal--success');
        }

        if (extraClass) modalCard.classList.add(extraClass);

        let icon = 'check-circle-2';
        if (isExport) icon = 'download';
        else if (isDanger) icon = 'triangle-alert';

        let primaryBtnClass = 'btn-modal-confirm';
        if (isExport) primaryBtnClass = 'btn-modal-export';
        else if (isDanger) primaryBtnClass = 'btn-modal-danger';

        modalCard.innerHTML = `
            <div class="modal-icon-box">
                <i data-lucide="${icon}"></i>
            </div>
            <h3>${title}</h3>
            <p>${message}</p>
            <div class="modal-actions">
                <button class="btn-modal ${primaryBtnClass}" id="modal-confirm-btn">${confirmText || (isExport ? 'Xuất file' : 'Đồng ý')}</button>
                <button class="btn-modal btn-modal-cancel" id="modal-cancel-btn">${cancelText || 'Hủy bỏ'}</button>
            </div>
        `;

        if (window.lucide) {
            lucide.createIcons();
        }

        modalOverlay.classList.add('show');
        modalCard.classList.add('show');

        const confirmBtn = document.getElementById('modal-confirm-btn');
        const cancelBtn = document.getElementById('modal-cancel-btn');

        const close = () => {
            modalOverlay.classList.remove('show');
            modalCard.classList.remove('show');
        };

        confirmBtn.onclick = () => {
            if (onConfirm) onConfirm();
            close();
        };

        cancelBtn.onclick = close;
        modalOverlay.onclick = close;
    },

    // Toast
    showToast: function (message) {
        const icon = 'check';

        let container = document.getElementById('global-toast-container');
        if (!container) {
            container = document.createElement('div');
            container.id = 'global-toast-container';
            container.className = 'toast-container';
            document.body.appendChild(container);
        }

        const toast = document.createElement('div');
        toast.className = 'toast-item';
        toast.innerHTML = `
            <div class="toast-icon toast-icon--success"><i data-lucide="${icon}"></i></div>
            <span class="toast-text">${message}</span>
        `;

        container.appendChild(toast);
        if (window.lucide) lucide.createIcons();

        setTimeout(() => {
            toast.style.opacity = '0';
            toast.style.transform = 'translateX(20px)';
            toast.style.transition = 'opacity 0.4s, transform 0.4s';
            setTimeout(() => toast.remove(), 400);
        }, 3000);
    },
    // Panel
    showPanel: function ({ title, bodyHtml, extraClass }) {
        let modalOverlay = document.getElementById('global-modal-overlay');
        let modalCard = document.getElementById('global-modal-card');

        if (!modalOverlay) {
            modalOverlay = document.createElement('div');
            modalOverlay.id = 'global-modal-overlay';
            modalOverlay.className = 'modal-overlay';
            document.body.appendChild(modalOverlay);
        }

        if (!modalCard) {
            modalCard = document.createElement('div');
            modalCard.id = 'global-modal-card';
            modalCard.className = 'modal-card';
            document.body.appendChild(modalCard);
        }

        modalCard.className = 'modal-card modal-card--panel';
        if (extraClass) modalCard.classList.add(extraClass);

        modalCard.innerHTML = `
            <div class="panel-modal__header">
                <div class="panel-header-inner">
                    <h3>${title}</h3>
                    <button class="panel-modal__close" id="panel-modal-close" aria-label="Đóng">
                        <i data-lucide="x"></i>
                    </button>
                </div>
            </div>
            <div class="panel-modal__body">
                <div class="panel-container">${bodyHtml}</div>
            </div>
        `;

        if (window.lucide) {
            lucide.createIcons();
        }

        modalOverlay.classList.add('show');
        modalCard.classList.add('show');

        const close = () => {
            modalOverlay.classList.remove('show');
            modalCard.classList.remove('show');
        };

        const closeBtn = document.getElementById('panel-modal-close');
        if (closeBtn) closeBtn.onclick = close;
        modalOverlay.onclick = close;
    },

    openAllActivitiesPanel: function () {
        const bodyHtml = `
            <div class="panel-list">
                <div class="panel-list__item">
                    <div class="panel-list__dot active"></div>
                    <div class="panel-list__content">
                        <h5>Cập nhật hồ sơ bệnh nhân mới</h5>
                        <p>Hệ thống vừa đồng bộ dữ liệu từ thiết bị đeo thông minh.</p>
                        <span>12 phút trước</span>
                    </div>
                </div>
                <div class="panel-list__item">
                    <div class="panel-list__dot"></div>
                    <div class="panel-list__content">
                        <h5>BS. Trần Thị B đã xem báo cáo</h5>
                        <p>Truy cập báo cáo tuần của Khoa Nội tổng quát.</p>
                        <span>45 phút trước</span>
                    </div>
                </div>
                <div class="panel-list__item">
                    <div class="panel-list__dot active"></div>
                    <div class="panel-list__content">
                        <h5>Tối ưu hóa mô hình AI</h5>
                        <p>Cập nhật tham số nhận diện cảm xúc giọng nói v2.4.</p>
                        <span>2 giờ trước</span>
                    </div>
                </div>
                <div class="panel-list__item">
                    <div class="panel-list__dot"></div>
                    <div class="panel-list__content">
                        <h5>Xuất báo cáo hàng tháng</h5>
                        <p>Báo cáo tháng 7 đã được gửi đến hội đồng quản trị.</p>
                        <span>4 giờ trước</span>
                    </div>
                </div>
                <div class="panel-list__item">
                    <div class="panel-list__dot active"></div>
                    <div class="panel-list__content">
                        <h5>Đăng nhập quản trị mới</h5>
                        <p>Phát hiện phiên đăng nhập từ thiết bị đã tin cậy.</p>
                        <span>6 giờ trước</span>
                    </div>
                </div>
            </div>
        `;

        this.showPanel({
            title: 'Tất cả hoạt động gần đây',
            bodyHtml,
            extraClass: 'modal-card--activities'
        });
    },

    openAllAlertsPanel: async function () {
        const API_BASE = 'https://careai-production.up.railway.app';
        
        const formatRelativeTime = (isoString) => {
            if (!isoString) return '-';
            const now = new Date();
            const past = new Date(isoString);
            const diffMs = now - past;
            const diffMin = Math.floor(diffMs / 60000);
            if (diffMin < 1) return 'Vừa xong';
            if (diffMin < 60) return `${diffMin} phút trước`;
            const diffHour = Math.floor(diffMin / 60);
            if (diffHour < 24) return `${diffHour} giờ trước`;
            const diffDay = Math.floor(diffHour / 24);
            return `${diffDay} ngày trước`;
        };

        const inferLevel = (msg) => {
            const lowKeywords = ['pin', 'thay đổi nhẹ', 'nhiệt độ'];
            const midKeywords = ['stress', 'spo2', 'áp lực', 'buồn'];
            const msgLower = (msg || '').toLowerCase();
            if (midKeywords.some(k => msgLower.includes(k))) return { text: 'TRUNG BÌNH', class: 'warning' };
            if (lowKeywords.some(k => msgLower.includes(k))) return { text: 'NHẸ', class: 'success' };
            return { text: 'CAO', class: 'danger' };
        };

        const bodyHtml = `
            <div class="panel-table-wrap">
                <table class="panel-table">
                    <thead>
                        <tr>
                            <th style="width: 150px;">Mức độ</th>
                            <th>Mô tả cảnh báo</th>
                            <th style="width: 150px;">Thời gian</th>
                        </tr>
                    </thead>
                    <tbody id="alerts-table-body">
                        <tr><td colspan="3" style="text-align:center; padding: 40px;">Đang tải dữ liệu...</td></tr>
                    </tbody>
                </table>
            </div>
        `;

        this.showPanel({
            title: 'Tất cả cảnh báo bất thường',
            bodyHtml,
            extraClass: 'modal-card--alerts'
        });

        try {
            const response = await fetch(`${API_BASE}/notification/admin/alerts`);
            const result = await response.json();
            const tableBody = document.getElementById('alerts-table-body');
            if (result.success && result.data && result.data.length > 0) {
                let rowsHtml = '';
                result.data.forEach(item => {
                    const level = inferLevel(item.motacanhbao);
                    const userIdText = item.nguoiDungId ? `Người dùng ID #${item.nguoiDungId}` : 'Hệ thống';
                    rowsHtml += `
                        <tr>
                            <td>
                                <div class="panel-alert-level panel-alert-level--${level.class}">
                                    <span class="panel-alert-dot panel-alert-dot--${level.class}"></span>
                                    ${level.text}
                                </div>
                            </td>
                            <td>${item.motacanhbao} - ${userIdText}</td>
                            <td class="panel-alert-time">${formatRelativeTime(item.thoigian)}</td>
                        </tr>
                    `;
                });
                tableBody.innerHTML = rowsHtml;
            } else {
                tableBody.innerHTML = '<tr><td colspan="3" style="text-align:center; padding: 40px;">Không có cảnh báo nào gần đây.</td></tr>';
            }
        } catch (err) {
            console.error('Lỗi tải cảnh báo:', err);
            const tableBody = document.getElementById('alerts-table-body');
            if (tableBody) tableBody.innerHTML = '<tr><td colspan="3" style="text-align:center; padding: 40px; color: var(--status-danger);">Lỗi khi kết nối đến máy chủ.</td></tr>';
        }
    },

    // Dropdown System
    toggleDropdown: function (id) {
        const dropdown = document.getElementById(id);
        if (dropdown) {
            const isShown = dropdown.classList.contains('show');
            document.querySelectorAll('.notif-dropdown, .header__dropdown').forEach(d => d.classList.remove('show'));

            if (!isShown) dropdown.classList.add('show');
        }
    }
};
window.UI = UI;

document.addEventListener('DOMContentLoaded', () => {
    UI.initTheme();
    initNavigationFeedback();
    document.addEventListener('click', (e) => {
        if (!e.target.closest('.header__action-wrapper') && !e.target.closest('.notif-dropdown')) {
            document.querySelectorAll('.notif-dropdown').forEach(d => d.classList.remove('show'));
        }
    });
});
