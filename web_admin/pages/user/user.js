const API_BASE = 'https://careai-production.up.railway.app';
const API = `${API_BASE}/profile`;
const PAGE_SIZE = 10;

let currentPage = 1;
let users = [];
let filteredUsers = [];
let currentSort = 'default';

function toAbsoluteImageUrl(path) {
    if (!path) return 'https://cdn-icons-png.flaticon.com/512/149/149071.png';
    if (/^https?:\/\//i.test(path)) return path;
    const cleanPath = path.startsWith('/') ? path : `/${path}`;
    return `${API_BASE}${cleanPath}`;
}

function formatDate(dateStr) {
    if (!dateStr) return '-';
    const d = new Date(dateStr);
    if (Number.isNaN(d.getTime())) return '-';
    return d.toLocaleDateString('vi-VN');
}

function getCurrentPage() {
    const byData = document.body?.dataset?.page;
    if (byData) return byData;

    const path = window.location.pathname.toLowerCase();
    if (path.includes('user-edit')) return 'user-edit';
    if (path.includes('user-view') || path.includes('user-detail')) return 'user-view';
    if (path.includes('user')) return 'user';
    return '';
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
            confirmText: type === 'danger' ? 'Xóa' : 'Xác nhận',
            cancelText: 'Hủy bỏ',
            onConfirm
        });
        return;
    }

    const ok = window.confirm(message || title || 'Xác nhận thao tác?');
    if (ok && typeof onConfirm === 'function') onConfirm();
}

// ──────────────────────────────────────────────────────────────────────────────
// LIST + TABLE
// ──────────────────────────────────────────────────────────────────────────────

function renderTable() {
    const tbody = document.querySelector('.premium-table tbody');
    const emptyState = document.getElementById('empty-state');
    const paginationRow = document.querySelector('.pagination-row');
    if (!tbody) return;

    const start = (currentPage - 1) * PAGE_SIZE;
    const pageData = filteredUsers.slice(start, start + PAGE_SIZE);

    if (filteredUsers.length === 0) {
        tbody.innerHTML = '';
        if (emptyState) emptyState.style.display = '';
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
                        <div class="user-mail">${u.email}</div>
                    </div>
                </div>
            </td>
            <td><span class="badge ${u.genderClass}">${u.gender}</span></td>
            <td>${u.phone}</td>
            <td>${u.created}</td>
            <td class="text-right">
                <div class="action-icons">
                    <button class="btn-icon" aria-label="Xem chi tiết" onclick="window.location.href='user-view.html?id=${u.id}'"><i data-lucide="eye"></i></button>
                    <button class="btn-icon" aria-label="Chỉnh sửa" onclick="window.location.href='user-edit.html?id=${u.id}'"><i data-lucide="edit-3"></i></button>
                    <button class="btn-icon btn-icon--danger" aria-label="Xóa người dùng" onclick="confirmDelete('${u.id}', '${u.name.replace(/'/g, "\\'")}')"><i data-lucide="trash-2"></i></button>
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

    let html = `<button class="page-link" aria-label="Chuyển trang" ${currentPage === 1 ? 'disabled' : ''} onclick="changePage(${currentPage - 1})"><i data-lucide="chevron-left"></i></button>`;

    for (let i = 1; i <= totalPages; i++) {
        if (totalPages > 6 && i > 3 && i < totalPages - 1) {
            if (i === 4) html += '<span class="page-dots">...</span>';
            continue;
        }
        html += `<button class="page-link ${i === currentPage ? 'active' : ''}" onclick="changePage(${i})">${i}</button>`;
    }

    html += `<button class="page-link" aria-label="Chuyển trang" ${currentPage === totalPages ? 'disabled' : ''} onclick="changePage(${currentPage + 1})"><i data-lucide="chevron-right"></i></button>`;

    controls.innerHTML = html;
    if (window.lucide) lucide.createIcons();
}

function updateCount() {
    const el = document.querySelector('.pagination-count');
    if (!el) return;

    const start = (currentPage - 1) * PAGE_SIZE + 1;
    const end = Math.min(currentPage * PAGE_SIZE, filteredUsers.length);

    el.textContent = filteredUsers.length === 0
        ? 'Không có dữ liệu'
        : `Hiển thị ${start} đến ${end} trong số ${filteredUsers.length} người dùng`;
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

    const base = q
        ? users.filter((u) =>
            u.name.toLowerCase().includes(q) ||
            u.email.toLowerCase().includes(q) ||
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

        users = (json?.data || []).map((u) => ({
            id: u.nguoiDungId || '',
            name: u.tenND || '(Chưa cập nhật)',
            email: u.email || '-',
            gender: u.gioiTinh ? 'Nam' : 'Nữ',
            genderClass: u.gioiTinh ? 'badge--info' : 'badge--pink',
            phone: u.soDienThoai || '-',
            created: formatDate(u.ngayTao),
            createdAtRaw: u.ngayTao || '',
            avatar: toAbsoluteImageUrl(u.avatarUrl)
        }));

        await updateUserStats();
        applyFiltersAndSort(document.querySelector('.search-field-shared input')?.value || '');
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
        title: 'Xóa tài khoản?',
        message: `Bạn có chắc chắn muốn xóa <strong>${name}</strong>? Hành động này không thể hoàn tác.`,
        onConfirm: async () => {
            try {
                const res = await fetch(`${API}/${userId}`, { method: 'DELETE' });
                const json = await res.json();

                if (!json?.success) {
                    toast(json?.message || 'Xóa thất bại');
                    return;
                }

                await fetchUsers();
                toast('Xóa thành công');
            } catch (error) {
                console.error(error);
                toast('Lỗi kết nối server');
            }
        }
    });
}

// ──────────────────────────────────────────────────────────────────────────────
// DETAIL
// ──────────────────────────────────────────────────────────────────────────────

async function loadUserDetail(id) {
    if (!id) return;

    try {
        const res = await fetch(`${API}/${id}`);
        const json = await res.json();
        const u = json?.data;
        if (!u) return;

        const avatar = document.getElementById('avatar');
        const name = document.getElementById('name');
        const updated = document.getElementById('updated');
        const fullName = document.getElementById('fullName');
        const phone = document.getElementById('phone');
        const dob = document.getElementById('dob');
        const gender = document.getElementById('gender');
        const height = document.getElementById('height');
        const weight = document.getElementById('weight');
        const email = document.getElementById('email');
        const address = document.getElementById('address');
        const editBtn = document.getElementById('editBtn');

        if (avatar) avatar.src = toAbsoluteImageUrl(u.avatarUrl);
        if (name) name.innerText = u.tenND ?? '-';

        const lastUpdate = u.ngayCapNhat || u.ngayTao;
        if (updated) {
            updated.innerText = lastUpdate
                ? `Cập nhật lần cuối: ${formatDate(lastUpdate)}`
                : '-';
        }

        if (fullName) fullName.innerText = u.tenND ?? '-';
        if (phone) phone.innerText = u.soDienThoai ?? '-';
        if (dob) dob.innerText = formatDate(u.ngaySinh);
        if (gender) gender.innerText = u.gioiTinh ? 'Nam' : 'Nữ';
        if (height) height.innerText = u.chieuCao ? `${u.chieuCao} cm` : '-';
        if (weight) weight.innerText = u.canNang ? `${u.canNang} kg` : '-';
        if (email) email.innerText = u.email ?? '-';
        if (address) address.innerText = u.diaChi ?? '-';
        if (editBtn) editBtn.href = `./user-edit.html?id=${id}`;
    } catch (error) {
        console.error(error);
    }
}

function initDetailDelete(id) {
    const btnDelete = document.getElementById('btnDeleteUser') || document.querySelector('.btn-delete');
    btnDelete?.addEventListener('click', () => {
        confirmDialog({
            type: 'danger',
            title: 'Xóa tài khoản?',
            message: 'Bạn có chắc chắn muốn xóa người dùng này không?',
            onConfirm: async () => {
                try {
                    const res = await fetch(`${API}/${id}`, { method: 'DELETE' });
                    const json = await res.json();
                    if (!json?.success) {
                        toast(json?.message || 'Xóa thất bại');
                        return;
                    }
                    toast('Xóa thành công');
                    setTimeout(() => {
                        window.location.href = './user.html';
                    }, 900);
                } catch (error) {
                    console.error(error);
                    toast('Lỗi kết nối server');
                }
            }
        });
    });
}

// ──────────────────────────────────────────────────────────────────────────────
// EDIT
// ──────────────────────────────────────────────────────────────────────────────

async function loadUserEdit(id) {
    if (!id) return;

    try {
        const res = await fetch(`${API}/${id}`);
        const json = await res.json();
        const u = json?.data;
        if (!u) return;

        const tenND = document.getElementById('tenND');
        const email = document.getElementById('email');
        const diaChi = document.getElementById('diaChi');
        const chieuCao = document.getElementById('chieuCao');
        const canNang = document.getElementById('canNang');
        const soDienThoai = document.getElementById('soDienThoai');
        const ngaySinh = document.getElementById('ngaySinh');
        const gioiTinh = document.getElementById('gioiTinh');
        const avatarPreview = document.getElementById('avatarPreview');

        if (tenND) tenND.value = u.tenND || '';
        if (email) email.value = u.email || '';
        if (diaChi) diaChi.value = u.diaChi || '';
        if (chieuCao) chieuCao.value = u.chieuCao || '';
        if (canNang) canNang.value = u.canNang || '';
        if (soDienThoai) soDienThoai.value = u.soDienThoai || '';

        if (ngaySinh && u.ngaySinh) {
            const date = new Date(u.ngaySinh);
            ngaySinh.value = date.toISOString().split('T')[0];
        }

        if (gioiTinh) gioiTinh.value = u.gioiTinh ? '1' : '0';
        if (avatarPreview) avatarPreview.src = toAbsoluteImageUrl(u.avatarUrl);
    } catch (error) {
        console.error('Load user edit error:', error);
    }
}

function initEditPage(id) {
    const btnSave = document.getElementById('btnSave');
    const btnCancel = document.getElementById('btnCancel');
    const btnChangeAvatar = document.getElementById('btnChangeAvatar');
    const avatarInput = document.getElementById('avatarInput');
    const avatarPreview = document.getElementById('avatarPreview');

    btnCancel?.addEventListener('click', () => {
        window.location.href = './user.html';
    });

    btnChangeAvatar?.addEventListener('click', () => {
        avatarInput?.click();
    });

    avatarInput?.addEventListener('change', () => {
        const file = avatarInput.files?.[0];
        if (!file) return;

        if (!file.type.startsWith('image/')) {
            alert('Vui lòng chọn file ảnh');
            avatarInput.value = '';
            return;
        }

        const reader = new FileReader();
        reader.onload = (e) => {
            if (avatarPreview) avatarPreview.src = e.target?.result || '';
        };
        reader.readAsDataURL(file);
    });

    btnSave?.addEventListener('click', () => {
        confirmDialog({
            type: 'success',
            title: 'Xác nhận lưu',
            message: 'Bạn có chắc chắn muốn lưu các thay đổi này không?',
            onConfirm: async () => {
                try {
                    const formData = new FormData();
                    formData.append('tenND', document.getElementById('tenND')?.value || '');
                    formData.append('ngaySinh', document.getElementById('ngaySinh')?.value || '');
                    formData.append('gioiTinh', document.getElementById('gioiTinh')?.value || '');
                    formData.append('chieuCao', document.getElementById('chieuCao')?.value || '');
                    formData.append('canNang', document.getElementById('canNang')?.value || '');
                    formData.append('email', document.getElementById('email')?.value || '');
                    formData.append('diaChi', document.getElementById('diaChi')?.value || '');

                    const file = avatarInput?.files?.[0];
                    if (file) formData.append('avatar', file);

                    const res = await fetch(`${API}/${id}`, {
                        method: 'PUT',
                        body: formData
                    });

                    const json = await res.json();
                    if (!json?.success) {
                        alert(json?.message || 'Cập nhật thất bại');
                        return;
                    }

                    toast('Cập nhật thành công');
                    setTimeout(() => {
                        window.location.href = './user.html';
                    }, 900);
                } catch (error) {
                    console.error(error);
                    alert('Lỗi kết nối server');
                }
            }
        });
    });
}

// ──────────────────────────────────────────────────────────────────────────────
// INIT
// ──────────────────────────────────────────────────────────────────────────────

document.addEventListener('DOMContentLoaded', async () => {
    const page = getCurrentPage();
    const id = new URLSearchParams(window.location.search).get('id');

    if (page === 'user') {
        initSearch();
        initSort();
        await fetchUsers();
    }

    if (page === 'user-view') {
        await loadUserDetail(id);
        initDetailDelete(id);
    }

    if (page === 'user-edit') {
        await loadUserEdit(id);
        initEditPage(id);
    }
});