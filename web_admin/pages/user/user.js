const API_BASE = 'https://careai-production.up.railway.app';
const API = `${API_BASE}/profile`;
const PAGE_SIZE = 10;
const DEFAULT_AVATAR = 'https://cdn-icons-png.flaticon.com/512/149/149071.png';

let currentPage = 1;
let users = [];
let filteredUsers = [];
let currentSort = 'default';
let isSearching = false;
const userDetailCache = new Map();

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

function toAbsoluteImageUrl(path) {
    if (!path) return DEFAULT_AVATAR;
    if (/^https?:\/\//i.test(path)) return path;
    const cleanPath = path.startsWith('/') ? path : `/${path}`;
    return `${API_BASE}${cleanPath}`;
}

function formatDate(dateStr) {
    if (!dateStr) return '-';
    const d = new Date(dateStr);
    if (Number.isNaN(d.getTime())) return '-';
    return d.toLocaleDateString(getCurrentLocale());
}

function getAccountRecord(user) {
    const account = user?.taikhoan;
    if (Array.isArray(account)) return account[0] || null;
    return account || null;
}

function pickFirstValue(...values) {
    for (const value of values) {
        if (value === undefined || value === null) continue;
        if (typeof value === 'string' && value.trim() === '') continue;
        return value;
    }
    return null;
}

function normalizeGenderValue(value) {
    if (value === 1 || value === '1' || value === true || value === 'true') return 1;
    if (value === 0 || value === '0' || value === false || value === 'false') return 0;
    if (value === 2 || value === '2') return 2;
    return null;
}

function mapUserRecord(user) {
    const account = getAccountRecord(user);
    const id = pickFirstValue(user?.nguoiDungId, user?.nguoidung_id, user?.id, '');
    const name = pickFirstValue(user?.tenND, user?.tennd, user?.name, t('(Chưa cập nhật)'));
    const phone = pickFirstValue(
        user?.soDienThoai,
        user?.sodienthoai,
        user?.phone,
        account?.soDienThoai,
        account?.sodienthoai
    );
    const createdAtRaw = pickFirstValue(
        user?.ngayTao,
        user?.ngaytao,
        account?.ngayTao,
        account?.ngaytao
    );
    const avatarPath = pickFirstValue(user?.avatarUrl, user?.avatarurl);
    const genderRaw = normalizeGenderValue(pickFirstValue(user?.gioiTinh, user?.gioitinh));

    const genderLabel = genderRaw === 1
        ? t('Nam')
        : (genderRaw === 0 ? t('Nữ') : (genderRaw === 2 ? t('Khác') : '-'));
    const genderClass = genderRaw === 1
        ? 'badge--info'
        : (genderRaw === 0 ? 'badge--pink' : (genderRaw === 2 ? 'badge--purple' : 'badge--neutral'));

    return {
        id: id ? String(id) : '',
        name: String(name),
        secondaryText: id ? `${id}` : '-',
        gender: genderLabel,
        genderClass,
        genderRaw,
        phone: phone ? String(phone) : '-',
        created: formatDate(createdAtRaw),
        createdAtRaw: createdAtRaw ? String(createdAtRaw) : '',
        avatar: toAbsoluteImageUrl(avatarPath)
    };
}

function needsUserDetail(user) {
    return user.phone === '-' || !user.createdAtRaw || user.avatar === DEFAULT_AVATAR || user.genderRaw === null;
}

async function fetchUserDetail(id) {
    if (!id) return null;
    if (userDetailCache.has(id)) return userDetailCache.get(id);

    const request = fetch(`${API}/${id}`)
        .then((res) => res.json())
        .then((json) => (json?.success ? json.data || null : null))
        .catch((error) => {
            console.error(`Load detail for user ${id} error:`, error);
            return null;
        });

    userDetailCache.set(id, request);
    return request;
}

async function hydrateUsersWithDetails(rawUsers, mappedUsers) {
    return Promise.all(mappedUsers.map(async (user, index) => {
        if (!needsUserDetail(user) || !user.id) return user;

        const detail = await fetchUserDetail(user.id);
        if (!detail) return user;

        return mapUserRecord({
            ...rawUsers[index],
            ...detail
        });
    }));
}

function toast(message) {
    if (window.UI?.showToast) {
        UI.showToast(message);
        return;
    }
    alert(message);
}

function confirmDialog({ title, message, type = 'danger', onConfirm }) {
    if (window.UI?.showModal) {
        UI.showModal({
            type,
            title,
            message,
            confirmText: type === 'danger' ? t('Xóa') : t('Xác nhận'),
            cancelText: t('Hủy bỏ'),
            onConfirm
        });
        return;
    }

    const ok = window.confirm(message || title || t('Xác nhận thao tác?'));
    if (ok && typeof onConfirm === 'function') onConfirm();
}

function renderTable() {
    const tbody = document.querySelector('.premium-table tbody');
    const emptyState = document.getElementById('empty-state');
    const paginationRow = document.querySelector('.pagination-row');
    if (!tbody) return;

    const start = (currentPage - 1) * PAGE_SIZE;
    const pageData = filteredUsers.slice(start, start + PAGE_SIZE);

    if (filteredUsers.length === 0) {
        tbody.innerHTML = `<tr><td colspan="5" style="text-align: center; padding: 40px; color: #64748B;">${isSearching ? t('Không có dữ liệu phù hợp') : t('Không có dữ liệu')}</td></tr>`;
        if (emptyState) emptyState.style.display = 'none';
        if (paginationRow) paginationRow.style.display = 'none';
        return;
    }

    if (emptyState) emptyState.style.display = 'none';
    if (paginationRow) paginationRow.style.display = '';

    tbody.innerHTML = pageData.map((u) => `
        <tr data-id="${u.id}">
            <td>
                <div class="user-cell">
                    <img src="${u.avatar}" alt="${u.name}">
                    <div class="user-info">
                        <div class="user-fullname">${u.name}</div>
                        <div class="user-mail">${u.secondaryText}</div>
                    </div>
                </div>
            </td>
            <td><span class="badge ${u.genderClass}">${u.gender}</span></td>
            <td>${u.phone}</td>
            <td>${u.created}</td>
            <td class="text-right">
                <div class="action-icons">
                    <button class="btn-icon" aria-label="${t('Xem chi tiết')}" onclick="window.location.href='user-view.html?id=${u.id}'"><i data-lucide="eye"></i></button>
                    <button class="btn-icon" aria-label="${t('Chỉnh sửa')}" onclick="window.location.href='user-edit.html?id=${u.id}'"><i data-lucide="edit-3"></i></button>
                    <button class="btn-icon btn-icon--danger" aria-label="${t('Xóa người dùng')}" onclick="confirmDelete('${u.id}', '${u.name.replace(/'/g, "\\'")}')"><i data-lucide="trash-2"></i></button>
                </div>
            </td>
        </tr>
    `).join('');

    if (window.lucide) lucide.createIcons();
    renderPagination();
    updateCount();
}

function renderPagination() {
    const controls = document.querySelector('.pagination-controls');
    if (!controls) return;

    const totalPages = Math.ceil(filteredUsers.length / PAGE_SIZE);
    if (!totalPages) {
        controls.innerHTML = '';
        return;
    }

    let html = `<button class="page-link" aria-label="${t('Chuyển trang')}" ${currentPage === 1 ? 'disabled' : ''} onclick="changePage(${currentPage - 1})"><i data-lucide="chevron-left"></i></button>`;

    for (let i = 1; i <= totalPages; i++) {
        if (totalPages > 6 && i > 3 && i < totalPages - 1) {
            if (i === 4) html += '<span class="page-dots">...</span>';
            continue;
        }
        html += `<button class="page-link ${i === currentPage ? 'active' : ''}" onclick="changePage(${i})">${i}</button>`;
    }

    html += `<button class="page-link" aria-label="${t('Chuyển trang')}" ${currentPage === totalPages ? 'disabled' : ''} onclick="changePage(${currentPage + 1})"><i data-lucide="chevron-right"></i></button>`;

    controls.innerHTML = html;
    if (window.lucide) lucide.createIcons();
}

function updateCount() {
    const el = document.querySelector('.pagination-count');
    if (!el) return;

    if (filteredUsers.length === 0) {
        el.textContent = '';
        return;
    }

    const start = (currentPage - 1) * PAGE_SIZE + 1;
    const end = Math.min(currentPage * PAGE_SIZE, filteredUsers.length);

    el.textContent = tf('Hiển thị {start} đến {end} trong số {count} người dùng', {
        start,
        end,
        count: filteredUsers.length
    });
}

async function updateUserStats() {
    const totalEl = document.getElementById('totalUsersValue');
    const newMonthEl = document.getElementById('newUsersMonthValue');
    const interactionRateValueEl = document.getElementById('interactionRateValue');
    const interactionRateTrendEl = document.getElementById('interactionRateTrend');

    if (totalEl) totalEl.textContent = String(users.length);

    const now = new Date();
    const month = now.getMonth();
    const year = now.getFullYear();

    const newThisMonth = users.filter((u) => {
        if (!u.createdAtRaw) return false;
        const d = new Date(u.createdAtRaw);
        if (Number.isNaN(d.getTime())) return false;
        return d.getMonth() === month && d.getFullYear() === year;
    }).length;

    if (newMonthEl) newMonthEl.textContent = String(newThisMonth);

    try {
        const res = await fetch(`${API_BASE}/api/chat/conversations`);
        const json = await res.json();
        const rows = json?.success ? (json.data || []) : [];

        const end = new Date();
        end.setHours(23, 59, 59, 999);

        const start7 = new Date(end);
        start7.setDate(end.getDate() - 6);
        start7.setHours(0, 0, 0, 0);

        const prevEnd = new Date(start7);
        prevEnd.setMilliseconds(-1);

        const prevStart = new Date(prevEnd);
        prevStart.setDate(prevEnd.getDate() - 6);
        prevStart.setHours(0, 0, 0, 0);

        const sumRange = (from, to) => rows.reduce((sum, item) => {
            const d = new Date(item.date);
            if (Number.isNaN(d.getTime())) return sum;
            if (d < from || d > to) return sum;
            return sum + Number(item.total || 0);
        }, 0);

        const current7 = sumRange(start7, end);
        const previous7 = sumRange(prevStart, prevEnd);

        const interactionRate = users.length > 0
            ? (current7 / users.length) * 100
            : 0;

        let trendPercent = 0;
        if (previous7 > 0) {
            trendPercent = ((current7 - previous7) / previous7) * 100;
        } else if (current7 > 0) {
            trendPercent = 100;
        }

        if (interactionRateValueEl) {
            interactionRateValueEl.textContent = `${interactionRate.toFixed(1)}%`;
        }

        if (interactionRateTrendEl) {
            const sign = trendPercent >= 0 ? '+' : '';
            interactionRateTrendEl.textContent = `${sign}${trendPercent.toFixed(1)}%`;
        }
    } catch (error) {
        console.error('Load interaction rate error:', error);
        if (interactionRateValueEl) interactionRateValueEl.textContent = '0%';
        if (interactionRateTrendEl) interactionRateTrendEl.textContent = '+0%';
    }
}

function sortUsersData(data, sortKey) {
    const arr = [...data];

    if (sortKey === 'name-asc') {
        arr.sort((a, b) => a.name.localeCompare(b.name, 'vi'));
    }

    if (sortKey === 'name-desc') {
        arr.sort((a, b) => b.name.localeCompare(a.name, 'vi'));
    }

    if (sortKey === 'created-newest') {
        arr.sort((a, b) => {
            const ad = a.createdAtRaw ? new Date(a.createdAtRaw).getTime() : 0;
            const bd = b.createdAtRaw ? new Date(b.createdAtRaw).getTime() : 0;
            return bd - ad;
        });
    }

    if (sortKey === 'created-oldest') {
        arr.sort((a, b) => {
            const ad = a.createdAtRaw ? new Date(a.createdAtRaw).getTime() : 0;
            const bd = b.createdAtRaw ? new Date(b.createdAtRaw).getTime() : 0;
            return ad - bd;
        });
    }

    return arr;
}

function applyFiltersAndSort(searchQuery = '') {
    const q = searchQuery.toLowerCase().trim();
    isSearching = q.length > 0;

    const base = q
        ? users.filter((u) =>
            u.name.toLowerCase().includes(q) ||
            u.secondaryText.toLowerCase().includes(q) ||
            u.phone.toLowerCase().includes(q)
        )
        : [...users];

    filteredUsers = sortUsersData(base, currentSort);
    currentPage = 1;
    renderTable();
}

function changePage(page) {
    const totalPages = Math.ceil(filteredUsers.length / PAGE_SIZE);
    if (page < 1 || page > totalPages) return;
    currentPage = page;
    renderTable();
}

async function fetchUsers() {
    try {
        const res = await fetch(API);
        const json = await res.json();
        const rawUsers = json?.data || [];

        users = rawUsers.map(mapUserRecord);
        await updateUserStats();
        applyFiltersAndSort(document.querySelector('.search-field-shared input')?.value || '');

        const hydratedUsers = await hydrateUsersWithDetails(rawUsers, users);
        const hasHydratedData = hydratedUsers.some((user, index) =>
            user.phone !== users[index]?.phone ||
            user.createdAtRaw !== users[index]?.createdAtRaw ||
            user.avatar !== users[index]?.avatar ||
            user.genderRaw !== users[index]?.genderRaw
        );

        if (hasHydratedData) {
            users = hydratedUsers;
            await updateUserStats();
            applyFiltersAndSort(document.querySelector('.search-field-shared input')?.value || '');
        }
    } catch (error) {
        console.error(error);
        users = [];
        filteredUsers = [];
        await updateUserStats();
        renderTable();
    }
}

function initSearch() {
    const input = document.querySelector('.search-field-shared input');
    if (!input) return;

    input.addEventListener('input', () => {
        applyFiltersAndSort(input.value || '');
    });
}

function initSort() {
    const sortSelect = document.getElementById('sortUsers');
    if (!sortSelect) return;

    sortSelect.addEventListener('change', () => {
        currentSort = sortSelect.value;
        const query = document.querySelector('.search-field-shared input')?.value || '';
        applyFiltersAndSort(query);
    });
}

async function confirmDelete(userId, name) {
    confirmDialog({
        type: 'danger',
        title: t('Xóa người dùng?'),
        message: tf('Bạn có chắc chắn muốn xóa <strong>{name}</strong>? Hành động này không thể hoàn tác.', { name }),
        onConfirm: async () => {
            try {
                const res = await fetch(`${API}/${userId}`, { method: 'DELETE' });
                const json = await res.json();

                if (!json?.success) {
                    toast(json?.message || t('Xóa thất bại'));
                    return;
                }

                await fetchUsers();
                toast(t('Xóa thành công'));
            } catch (error) {
                console.error(error);
                toast(t('Lỗi kết nối server'));
            }
        }
    });
}

document.addEventListener('DOMContentLoaded', async () => {
    initSearch();
    initSort();
    await fetchUsers();
});

document.addEventListener('care-ai-language-changed', async () => {
    users = users.map((user) => ({
        ...user,
        created: formatDate(user.createdAtRaw),
        gender: user.genderRaw === 1 ? t('Nam') : (user.genderRaw === 0 ? t('Nữ') : (user.genderRaw === 2 ? t('Khác') : '-'))
    }));
    filteredUsers = sortUsersData([...filteredUsers].map((user) => ({
        ...user,
        created: formatDate(user.createdAtRaw),
        gender: user.genderRaw === 1 ? t('Nam') : (user.genderRaw === 0 ? t('Nữ') : (user.genderRaw === 2 ? t('Khác') : '-'))
    })), currentSort);
    renderTable();
});
