const API_BASE = 'https://careai-production.up.railway.app';
const API = `${API_BASE}/profile`;
const DEFAULT_AVATAR = 'https://cdn-icons-png.flaticon.com/512/149/149071.png';

let currentUserId = null;

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

async function loadUserDetail(id) {
    if (!id) return;
    currentUserId = id;

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
                ? tf('Cập nhật lần cuối: {date}', { date: formatDate(lastUpdate) })
                : '-';
        }

        if (fullName) fullName.innerText = u.tenND ?? '-';
        if (phone) phone.innerText = u.soDienThoai ?? '-';
        if (dob) dob.innerText = formatDate(u.ngaySinh);
        if (gender) {
            const genderValue = u.gioiTinh === 1 || u.gioiTinh === true || u.gioiTinh === '1';
            gender.innerText = genderValue ? t('Nam') : t('Nữ');
        }
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
            title: t('Xóa tài khoản?'),
            message: t('Bạn có chắc chắn muốn xóa người dùng này không?'),
            onConfirm: async () => {
                try {
                    const res = await fetch(`${API}/${id}`, { method: 'DELETE' });
                    const json = await res.json();
                    if (!json?.success) {
                        toast(json?.message || t('Xóa thất bại'));
                        return;
                    }
                    toast(t('Xóa thành công'));
                    setTimeout(() => {
                        window.location.href = './user.html';
                    }, 900);
                } catch (error) {
                    console.error(error);
                    toast(t('Lỗi kết nối server'));
                }
            }
        });
    });
}

document.addEventListener('DOMContentLoaded', async () => {
    const id = new URLSearchParams(window.location.search).get('id');
    await loadUserDetail(id);
    initDetailDelete(id);
});

document.addEventListener('care-ai-language-changed', async () => {
    if (currentUserId) {
        await loadUserDetail(currentUserId);
    }
});
