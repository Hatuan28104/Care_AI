const API_BASE = 'https://careai-production.up.railway.app';

const API_USERS_DASHBOARD = `${API_BASE}/profile/dashboard/users`;
const API_CONVERSATIONS = `${API_BASE}/api/chat/conversations`;
const API_ALERTS = `${API_BASE}/notification/admin/alerts`;

let userGrowthChartInstance = null;
let interactionChartInstance = null;
let selectedStart = null;
let selectedEnd = null;
let pickerInstance = null;

function t(key) {
    return window.I18n?.t(key) || key;
}

function tf(key, params = {}) {
    if (window.I18n?.format) return window.I18n.format(key, params);
    return key.replace(/\{(\w+)\}/g, (_, token) => params[token] ?? '');
}

function getCurrentLocale() {
    return window.I18n?.getCurrentLang?.() === 'en' ? 'en-US' : 'vi-VN';
}

async function fetchData(url) {
    const res = await fetch(url);
    const json = await res.json();

    if (!json?.success) {
        console.error('API ERROR:', url, json);
        return [];
    }

    return json.data || [];
}

function isInRange(date, start, end) {
    if (!(date instanceof Date) || Number.isNaN(date.getTime())) return false;
    if (!start || !end) return true;
    return date >= start && date <= end;
}

function toDateKey(date) {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
}

function groupByDate(data, dateField, valueField = null) {
    const map = {};

    data.forEach((item) => {
        if (!item?.[dateField]) return;

        const d = new Date(item[dateField]);
        if (Number.isNaN(d.getTime())) return;
        if (!isInRange(d, selectedStart, selectedEnd)) return;

        const key = toDateKey(d);
        const value = valueField ? Number(item[valueField] || 0) : 1;

        map[key] = (map[key] || 0) + value;
    });

    return map;
}

function toChartSeries(map) {
    const sorted = Object.entries(map).sort((a, b) => new Date(a[0]) - new Date(b[0]));

    return {
        labels: sorted.map(([date]) => new Date(date).toLocaleDateString(getCurrentLocale())),
        values: sorted.map(([, value]) => value)
    };
}

function initCharts() {
    if (typeof Chart === 'undefined') return;

    Chart.defaults.font.family = "'Be Vietnam Pro', sans-serif";
    Chart.defaults.color = '#94A3B8';

    const growthCanvas = document.getElementById('userGrowthChart');
    if (growthCanvas) {
        const ctxGrowth = growthCanvas.getContext('2d');
        userGrowthChartInstance = new Chart(ctxGrowth, {
            type: 'line',
            data: { labels: [], datasets: [] },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: '#1E293B',
                        padding: 12,
                        titleFont: { size: 14, weight: '700' },
                        bodyFont: { size: 13 },
                        cornerRadius: 8,
                        displayColors: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: '#CBD5E1', drawBorder: false, borderDash: [5, 5] }
                    },
                    x: {
                        grid: { color: '#CBD5E1', drawBorder: false, borderDash: [5, 5], display: true }
                    }
                }
            }
        });
    }

    const interactionCanvas = document.getElementById('interactionChart');
    if (interactionCanvas) {
        const ctxInteraction = interactionCanvas.getContext('2d');
        interactionChartInstance = new Chart(ctxInteraction, {
            type: 'bar',
            data: { labels: [], datasets: [] },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: { backgroundColor: '#1E293B', padding: 12, cornerRadius: 8 }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: '#CBD5E1', drawBorder: false, borderDash: [5, 5] }
                    },
                    x: {
                        grid: { color: '#CBD5E1', drawBorder: false, borderDash: [5, 5], display: true }
                    }
                }
            }
        });
    }
}

function updateUserGrowthChart(labels, values) {
    if (!userGrowthChartInstance) return;

    userGrowthChartInstance.data.labels = labels;
    userGrowthChartInstance.data.datasets = [{
        label: t('Người dùng mới'),
        data: values,
        borderColor: '#1877F2',
        borderWidth: 2,
        pointBackgroundColor: '#FFFFFF',
        pointBorderColor: '#1877F2',
        pointBorderWidth: 2,
        pointRadius: 4,
        pointHoverRadius: 6,
        tension: 0.3,
        fill: false
    }];

    userGrowthChartInstance.update();
}

function updateInteractionChart(labels, values) {
    if (!interactionChartInstance) return;

    interactionChartInstance.data.labels = labels;
    interactionChartInstance.data.datasets = [{
        label: t('Lượt tương tác'),
        data: values,
        backgroundColor: '#1877F2',
        borderRadius: 12,
        hoverBackgroundColor: '#1565C0'
    }];

    interactionChartInstance.update();
}

function formatCompactNumber(value) {
    return Number(value || 0).toLocaleString(getCurrentLocale());
}

function setKPI(id, value) {
    const el = document.getElementById(id);
    if (!el) return;
    el.textContent = formatCompactNumber(value);
}

function formatRelativeTime(isoString) {
    if (!isoString) return '-';

    const now = new Date();
    const past = new Date(isoString);
    const diffMs = now - past;
    const diffMin = Math.floor(diffMs / 60000);

    if (diffMin < 1) return t('Vừa xong');
    if (diffMin < 60) return tf('{count} phút trước', { count: diffMin });

    const diffHour = Math.floor(diffMin / 60);
    if (diffHour < 24) return tf('{count} giờ trước', { count: diffHour });

    const diffDay = Math.floor(diffHour / 24);
    return tf('{count} ngày trước', { count: diffDay });
}

function inferLevel(msg) {
    const lowKeywords = ['pin', 'thay đổi nhẹ', 'nhiệt độ'];
    const midKeywords = ['stress', 'spo2', 'áp lực', 'buồn'];
    const msgLower = (msg || '').toLowerCase();

    if (midKeywords.some((k) => msgLower.includes(k))) {
        return { text: t('TRUNG BÌNH'), class: 'warning' };
    }

    if (lowKeywords.some((k) => msgLower.includes(k))) {
        return { text: t('NHẸ'), class: 'success' };
    }

    return { text: t('CAO'), class: 'danger' };
}

function renderRecentAlerts(alerts) {
    const tableBody = document.getElementById('dashboard-alerts-body');
    if (!tableBody) return;

    if (!alerts || alerts.length === 0) {
        tableBody.innerHTML = `<tr><td colspan="3" style="text-align:center; padding: 24px;">${t('Không có cảnh báo nào gần đây.')}</td></tr>`;
        return;
    }

    const recent = alerts.slice(0, 4);
    let rowsHtml = '';

    recent.forEach((item) => {
        const level = inferLevel(item.motacanhbao);
        const userIdText = item.nguoiDungId
            ? tf('Người dùng ID #{id}', { id: item.nguoiDungId })
            : t('Hệ thống');

        let displayMsg = item.motacanhbao;
        const msgLower = (item.motacanhbao || '').toLowerCase();

        if (item.tinnhan_id) {
            displayMsg = tf('Phát hiện ngôn ngữ tiêu cực: "{message}"', {
                message: item.motacanhbao
            });
        } else if (msgLower.includes('nhịp tim')) {
            displayMsg = tf('Cảnh báo nhịp tim: {message}', { message: item.motacanhbao });
        } else if (msgLower.includes('stress') || msgLower.includes('áp lực')) {
            displayMsg = tf('Cảnh báo mức độ căng thẳng: {message}', {
                message: item.motacanhbao
            });
        } else if (msgLower.includes('spo2') || msgLower.includes('oxy')) {
            displayMsg = tf('Cảnh báo nồng độ oxy máu: {message}', {
                message: item.motacanhbao
            });
        } else if (msgLower.includes('giấc ngủ') || msgLower.includes('ngủ')) {
            displayMsg = tf('Cảnh báo giấc ngủ: {message}', { message: item.motacanhbao });
        } else if (level.class === 'danger' || level.class === 'warning') {
            displayMsg = tf('Cảnh báo sức khỏe: {message}', { message: item.motacanhbao });
        }

        rowsHtml += `
            <tr>
                <td class="alert-cell--first">
                    <div class="alert-level alert-level--${level.class}">
                        <div class="alert-dot alert-dot--${level.class}"></div>
                        ${level.text}
                    </div>
                </td>
                <td class="alert-desc">${displayMsg} - ${userIdText}</td>
                <td class="alert-cell--last alert-time">${formatRelativeTime(item.thoigian)}</td>
            </tr>
        `;
    });

    tableBody.innerHTML = rowsHtml;
}

async function loadDashboardData() {
    try {
        const [users, conversations, alerts] = await Promise.all([
            fetchData(API_USERS_DASHBOARD),
            fetchData(API_CONVERSATIONS),
            fetchData(API_ALERTS)
        ]);

        const usersMap = groupByDate(users, 'ngaytao');
        const interactionsMap = groupByDate(conversations, 'date', 'total');
        const alertsMap = groupByDate(alerts, 'thoigian');

        const usersSeries = toChartSeries(usersMap);
        const interactionsSeries = toChartSeries(interactionsMap);

        updateUserGrowthChart(usersSeries.labels, usersSeries.values);
        updateInteractionChart(interactionsSeries.labels, interactionsSeries.values);

        const totalUsers = users.length;
        const totalInteractions = interactionsSeries.values.reduce((sum, v) => sum + v, 0);
        const totalAlerts = Object.values(alertsMap).reduce((sum, v) => sum + v, 0);

        const newUsers = users.filter((u) => {
            if (!u?.ngaytao) return false;
            const d = new Date(u.ngaytao);
            return isInRange(d, selectedStart, selectedEnd);
        }).length;

        setKPI('totalUsers', totalUsers);
        setKPI('newUsers', newUsers);
        setKPI('totalInteractions', totalInteractions);
        setKPI('totalAlerts', totalAlerts);

        renderRecentAlerts(alerts);
    } catch (error) {
        console.error('Load dashboard data error:', error);
    }
}

function exportCSV(filename, rows) {
    const csvContent = rows
        .map((row) => row.map((v) => `"${v ?? ''}"`).join(','))
        .join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = filename;
    link.click();
}

function pushSection(rows, title, map) {
    rows.push([`=== ${title} ===`]);
    rows.push(['Date', 'Total']);

    Object.entries(map)
        .sort((a, b) => new Date(a[0]) - new Date(b[0]))
        .forEach(([date, value]) => {
            rows.push([date, value]);
        });

    rows.push([]);
}

function initExport() {
    const exportBtn = document.getElementById('exportReportBtn');
    if (!exportBtn) return;

    exportBtn.addEventListener('click', () => {
        const onConfirmExport = async () => {
            try {
                const [users, conversations, alerts] = await Promise.all([
                    fetchData(API_USERS_DASHBOARD),
                    fetchData(API_CONVERSATIONS),
                    fetchData(API_ALERTS)
                ]);

                const rows = [];
                pushSection(rows, 'USERS', groupByDate(users, 'ngaytao'));
                pushSection(rows, 'INTERACTIONS', groupByDate(conversations, 'date', 'total'));
                pushSection(rows, 'ALERTS', groupByDate(alerts, 'thoigian'));

                exportCSV('dashboard_all.csv', rows);
                if (window.UI?.showToast) {
                    UI.showToast(t('Xuất báo cáo thành công'));
                }
            } catch (error) {
                console.error('Export error:', error);
            }
        };

        if (window.UI?.showModal) {
            UI.showModal({
                type: 'export',
                title: t('Xác nhận xuất file'),
                message: t('Bạn có chắc chắn muốn xuất báo cáo này không?'),
                confirmText: t('Đồng ý'),
                cancelText: t('Hủy bỏ'),
                onConfirm: onConfirmExport
            });
            return;
        }

        onConfirmExport();
    });
}

function initDatePicker() {
    const pickerInput = document.getElementById('dashboardDatePicker');
    if (!pickerInput || typeof Litepicker === 'undefined') return;

    try {
        pickerInstance?.destroy?.();
    } catch (_) {}

    const today = new Date();
    const startOfLast7Days = new Date(today);
    startOfLast7Days.setDate(today.getDate() - 6);
    startOfLast7Days.setHours(0, 0, 0, 0);
    today.setHours(23, 59, 59, 999);

    selectedStart = new Date(startOfLast7Days);
    selectedEnd = new Date(today);

    pickerInstance = new Litepicker({
        element: pickerInput,
        singleMode: false,
        numberOfMonths: 1,
        numberOfColumns: 1,
        dropdowns: {
            minYear: 2020,
            maxYear: null,
            months: true,
            years: true
        },
        lang: getCurrentLocale(),
        format: 'DD/MM/YYYY',
        buttonText: {
            apply: t('Áp dụng'),
            cancel: t('Hủy')
        },
        tooltipText: {
            one: t('ngày'),
            other: t('ngày')
        },
        setup: (instance) => {
            instance.on('selected', (date1, date2) => {
                selectedStart = date1.toJSDate();
                selectedStart.setHours(0, 0, 0, 0);

                selectedEnd = date2.toJSDate();
                selectedEnd.setHours(23, 59, 59, 999);

                loadDashboardData();
            });
        }
    });

    pickerInstance.setDateRange(startOfLast7Days, today);
}

document.addEventListener('DOMContentLoaded', async () => {
    initCharts();
    initExport();
    initDatePicker();
    await loadDashboardData();
});

document.addEventListener('care-ai-language-changed', async () => {
    initDatePicker();
    await loadDashboardData();
});
