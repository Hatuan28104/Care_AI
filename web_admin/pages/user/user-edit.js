const API_BASE = 'https://careai-production.up.railway.app';
const API = `${API_BASE}/profile`;
const DEFAULT_AVATAR = 'https://cdn-icons-png.flaticon.com/512/149/149071.png';

function t(key) {
    return window.I18n?.t(key) || key;
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

        const genderSwitcher = document.getElementById('genderSwitcher');
        if (genderSwitcher) {
            const val = u.gioiTinh ? '1' : '0';
            genderSwitcher.querySelectorAll('.gender-btn').forEach((btn) => {
                btn.classList.toggle('active', btn.dataset.value === val);
            });
        }

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
    const gioiTinh = document.getElementById('gioiTinh');

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
            alert(t('Vui lòng chọn file ảnh'));
            avatarInput.value = '';
            return;
        }

        const reader = new FileReader();
        reader.onload = (e) => {
            if (avatarPreview) avatarPreview.src = e.target?.result || '';
        };
        reader.readAsDataURL(file);
    });

    const genderSwitcher = document.getElementById('genderSwitcher');
    if (genderSwitcher) {
        genderSwitcher.querySelectorAll('.gender-btn').forEach((btn) => {
            btn.addEventListener('click', () => {
                genderSwitcher.querySelectorAll('.gender-btn').forEach((b) => b.classList.remove('active'));
                btn.classList.add('active');
                if (gioiTinh) gioiTinh.value = btn.dataset.value;
            });
        });
    }

    btnSave?.addEventListener('click', () => {
        const tenND = document.getElementById('tenND')?.value?.trim();
        const ngaySinh = document.getElementById('ngaySinh')?.value;
        const chieuCao = document.getElementById('chieuCao')?.value;
        const canNang = document.getElementById('canNang')?.value;
        const email = document.getElementById('email')?.value?.trim();

        if (!tenND) {
            toast(t('Vui lòng nhập tên người dùng'));
            return;
        }

        if (ngaySinh) {
            const birthDate = new Date(ngaySinh);
            const today = new Date();
            const age = today.getFullYear() - birthDate.getFullYear();
            const monthDiff = today.getMonth() - birthDate.getMonth();
            const actualAge = monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate()) ? age - 1 : age;

            if (actualAge < 16) {
                toast(t('Người dùng phải ít nhất 16 tuổi'));
                return;
            }
        }

        if (chieuCao && (chieuCao < 50 || chieuCao > 300)) {
            toast(t('Chiều cao phải từ 50 đến 300 cm'));
            return;
        }

        if (canNang && (canNang < 10 || canNang > 500)) {
            toast(t('Cân nặng phải từ 10 đến 500 kg'));
            return;
        }

        if (email && !/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(email)) {
            toast(t('Email không đúng định dạng'));
            return;
        }

        confirmDialog({
            type: 'success',
            title: t('Xác nhận lưu thay đổi'),
            message: t('Bạn có chắc chắn muốn lưu các thay đổi này không?'),
            onConfirm: async () => {
                try {
                    const formData = new FormData();
                    formData.append('tenND', tenND);
                    formData.append('ngaySinh', ngaySinh || '');
                    formData.append('gioiTinh', document.getElementById('gioiTinh')?.value || '');
                    formData.append('chieuCao', chieuCao || '');
                    formData.append('canNang', canNang || '');
                    formData.append('soDienThoai', document.getElementById('soDienThoai')?.value || '');
                    formData.append('email', email || '');
                    formData.append('diaChi', document.getElementById('diaChi')?.value || '');

                    const file = avatarInput?.files?.[0];
                    if (file) formData.append('avatar', file);

                    const res = await fetch(`${API}/${id}`, {
                        method: 'PUT',
                        body: formData
                    });

                    const json = await res.json();
                    if (!json?.success) {
                        alert(json?.message || t('Cập nhật thất bại'));
                        return;
                    }

                    toast(t('Cập nhật thành công'));
                    setTimeout(() => {
                        window.location.href = './user.html';
                    }, 900);
                } catch (error) {
                    console.error(error);
                    alert(t('Lỗi kết nối server'));
                }
            }
        });
    });
}

document.addEventListener('DOMContentLoaded', async () => {
    const id = new URLSearchParams(window.location.search).get('id');
    await loadUserEdit(id);
    initEditPage(id);
});
