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

    openAllAlertsPanel: function () {
        const bodyHtml = `
            <div class="panel-table-wrap">
                <table class="panel-table">
                    <thead>
                        <tr>
                            <th>Mức độ</th>
                            <th>Mô tả cảnh báo</th>
                            <th>Thời gian</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>
                                <div class="panel-alert-level panel-alert-level--danger">
                                    <span class="panel-alert-dot panel-alert-dot--danger"></span>
                                    CAO
                                </div>
                            </td>
                            <td>Phát hiện ngôn ngữ tiêu cực: "Tôi muốn chết" - Người dùng ID #8829</td>
                            <td class="panel-alert-time">2 phút trước</td>
                        </tr>
                        <tr>
                            <td>
                                <div class="panel-alert-level panel-alert-level--danger">
                                    <span class="panel-alert-dot panel-alert-dot--danger"></span>
                                    CAO
                                </div>
                            </td>
                            <td>Nhịp tim nghỉ ngơi tăng cao bất thường (110 bpm) - Người dùng ID #1022</td>
                            <td class="panel-alert-time">15 phút trước</td>
                        </tr>
                        <tr>
                            <td>
                                <div class="panel-alert-level panel-alert-level--warning">
                                    <span class="panel-alert-dot panel-alert-dot--warning"></span>
                                    TRUNG BÌNH
                                </div>
                            </td>
                            <td>Dấu hiệu Stress cao kéo dài (Chỉ số: 85/100) - Người dùng ID #4552</td>
                            <td class="panel-alert-time">1 giờ trước</td>
                        </tr>
                        <tr>
                            <td>
                                <div class="panel-alert-level panel-alert-level--success">
                                    <span class="panel-alert-dot panel-alert-dot--success"></span>
                                    NHẸ
                                </div>
                            </td>
                            <td>Thay đổi chu kỳ giấc ngủ đột ngột (Ngủ ít hơn 3h/đêm) - Người dùng ID #9921</td>
                            <td class="panel-alert-time">3 giờ trước</td>
                        </tr>
                        <tr>
                            <td>
                                <div class="panel-alert-level panel-alert-level--danger">
                                    <span class="panel-alert-dot panel-alert-dot--danger"></span>
                                    CAO
                                </div>
                            </td>
                            <td>Truy vấn API bất thường vượt ngưỡng giới hạn</td>
                            <td class="panel-alert-time">5 giờ trước</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        `;

        this.showPanel({
            title: 'Tất cả cảnh báo bất thường',
            bodyHtml,
            extraClass: 'modal-card--alerts'
        });
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
