const API_BASE = 'https://careai-production.up.railway.app';

function t(key) {
    return window.I18n?.t(key) || key;
}

function togglePassword() {
    const input = document.getElementById('password');
    const icon = document.getElementById('eyeIcon');

    const isHidden = input.type === 'password';
    input.type = isHidden ? 'text' : 'password';

    if (icon) {
        icon.setAttribute('data-lucide', isHidden ? 'eye' : 'eye-off');
        if (window.lucide) lucide.createIcons();
    }
}

async function login() {
    const phone = document.getElementById('sdt').value.trim();
    const password = document.getElementById('password').value.trim();
    const error = document.getElementById('loginError');

    error.style.display = 'none';

    if (!phone || !password) {
        error.innerText = t('Vui lòng nhập số điện thoại và mật khẩu');
        error.style.display = 'block';
        return;
    }

    try {
        const res = await fetch(`${API_BASE}/auth/admin/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                sodienthoai: phone,
                matkhau: password
            })
        });

        const data = await res.json();

        if (!data.success) {
            throw new Error(data.message || t('Đăng nhập thất bại'));
        }

        localStorage.setItem('token', data.token);
        localStorage.setItem('user_phone', phone);

        window.location.href = '../dashboard/dashboard.html';
    } catch (err) {
        error.innerText = err.message;
        error.style.display = 'block';
    }
}

document.addEventListener('DOMContentLoaded', () => {
    window.I18n?.init?.();
});
