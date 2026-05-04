const API_BASE = localStorage.getItem('care_ai_api_base') || 'https://careai-production.up.railway.app';
const REMEMBER_PHONE_KEY = 'care_ai_admin_phone';

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

function setButtonLoading(button, isLoading, loadingText, defaultText) {
    if (!button) return;
    button.disabled = isLoading;
    button.innerText = defaultText;
}

function showError(elementId, message) {
    const el = document.getElementById(elementId);
    if (!el) return;
    el.innerText = message;
    el.style.display = 'block';
}

function showMessage(elementId, message) {
    const el = document.getElementById(elementId);
    if (!el) return;
    el.innerText = message;
    el.style.display = 'block';
}

function clearFeedback() {
    ['loginError', 'loginStatus', 'forgotError'].forEach((id) => {
        const el = document.getElementById(id);
        if (el) {
            el.innerText = '';
            el.style.display = 'none';
        }
    });
}

function formatApiError(data, fallback) {
    const message = data?.message || fallback;
    if (message?.startsWith('API not found:')) {
        return '';
    }
    return message;
}

function showForgotPassword() {
    clearFeedback();
    document.getElementById('loginPanel')?.classList.add('hidden');
    document.getElementById('forgotPanel')?.classList.remove('hidden');

    const currentPhone = document.getElementById('sdt')?.value.trim();
    if (currentPhone) {
        document.getElementById('forgotPhone').value = currentPhone;
    }
}

function showLogin() {
    clearFeedback();
    document.getElementById('forgotPanel')?.classList.add('hidden');
    document.getElementById('loginPanel')?.classList.remove('hidden');
    document.getElementById('forgotPhone').disabled = false;
    document.getElementById('sendOtpButton')?.classList.remove('hidden');
    document.getElementById('resetFields')?.classList.add('hidden');
    document.getElementById('resetPasswordFields')?.classList.add('hidden');
    const otpInput = document.getElementById('resetOtp');
    const newPasswordInput = document.getElementById('newPassword');
    if (otpInput) otpInput.value = '';
    if (newPasswordInput) newPasswordInput.value = '';
    if (otpInput) otpInput.disabled = false;
    document.getElementById('verifyOtpButton')?.classList.remove('hidden');
}

async function login() {
    const phone = document.getElementById('sdt').value.trim();
    const password = document.getElementById('password').value.trim();
    const rememberLogin = document.getElementById('rememberLogin').checked;
    const button = document.getElementById('loginButton');

    clearFeedback();

    if (!phone || !password) {
        showError('loginError', t('Vui lòng nhập số điện thoại và mật khẩu'));
        return;
    }

    try {
        setButtonLoading(button, true, t('Đang đăng nhập...'), t('Đăng nhập'));

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
            throw new Error(formatApiError(data, t('Đăng nhập thất bại')));
        }

        if (rememberLogin) {
            sessionStorage.removeItem('token');
            sessionStorage.removeItem('user_phone');
            localStorage.setItem('token', data.token);
            localStorage.setItem('user_phone', phone);
            localStorage.setItem(REMEMBER_PHONE_KEY, phone);
        } else {
            localStorage.removeItem('token');
            localStorage.removeItem('user_phone');
            localStorage.removeItem(REMEMBER_PHONE_KEY);
            sessionStorage.setItem('token', data.token);
            sessionStorage.setItem('user_phone', phone);
        }

        window.location.href = '../dashboard/dashboard.html';
    } catch (err) {
        showError('loginError', err.message);
    } finally {
        setButtonLoading(button, false, t('Đang đăng nhập...'), t('Đăng nhập'));
    }
}

async function requestResetOtp() {
    const phone = document.getElementById('forgotPhone').value.trim();
    const button = document.getElementById('sendOtpButton');

    clearFeedback();

    if (!phone) {
        showError('forgotError', t('Vui lòng nhập số điện thoại'));
        return;
    }

    try {
        setButtonLoading(button, true, t('Đang gửi...'), t('Gửi OTP'));

        const res = await fetch(`${API_BASE}/auth/admin/forgot-password/request-otp`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ sodienthoai: phone })
        });

        const data = await res.json();

        if (!data.success) {
            throw new Error(formatApiError(data, t('Không thể gửi OTP')));
        }

        document.getElementById('resetFields')?.classList.remove('hidden');
        document.getElementById('resetPasswordFields')?.classList.add('hidden');
        const otpInput = document.getElementById('resetOtp');
        const newPasswordInput = document.getElementById('newPassword');
        if (otpInput) {
            otpInput.value = '';
            otpInput.disabled = false;
        }
        if (newPasswordInput) newPasswordInput.value = '';
        document.getElementById('verifyOtpButton')?.classList.remove('hidden');
        document.getElementById('sendOtpButton')?.classList.add('hidden');
        document.getElementById('forgotPhone').disabled = true;
    } catch (err) {
        showError('forgotError', err.message);
    } finally {
        setButtonLoading(button, false, t('Đang gửi...'), t('Gửi OTP'));
    }
}

async function verifyResetOtp() {
    const phone = document.getElementById('forgotPhone').value.trim();
    const otpInput = document.getElementById('resetOtp');
    const otp = otpInput.value.trim();
    const button = document.getElementById('verifyOtpButton');

    clearFeedback();

    if (!phone || !otp) {
        showError('forgotError', t('Vui lòng nhập số điện thoại và OTP'));
        return;
    }

    try {
        setButtonLoading(button, true, t('Đang xác nhận...'), t('Xác nhận OTP'));

        const res = await fetch(`${API_BASE}/auth/admin/forgot-password/verify-otp`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ sodienthoai: phone, otp })
        });

        const data = await res.json();

        if (!data.success) {
            throw new Error(formatApiError(data, t('OTP không đúng')));
        }

        otpInput.disabled = true;
        button.classList.add('hidden');
        document.getElementById('resetPasswordFields')?.classList.remove('hidden');
    } catch (err) {
        document.getElementById('resetPasswordFields')?.classList.add('hidden');
        showError('forgotError', err.message);
    } finally {
        setButtonLoading(button, false, t('Đang xác nhận...'), t('Xác nhận OTP'));
    }
}

async function resetPassword() {
    const phone = document.getElementById('forgotPhone').value.trim();
    const otp = document.getElementById('resetOtp').value.trim();
    const newPassword = document.getElementById('newPassword').value.trim();
    const button = document.getElementById('resetPasswordButton');

    clearFeedback();

    if (!phone || !otp || !newPassword) {
        showError('forgotError', t('Vui lòng nhập đầy đủ số điện thoại, OTP và mật khẩu mới'));
        return;
    }

    if (newPassword.length < 6) {
        showError('forgotError', t('Mật khẩu mới phải có ít nhất 6 ký tự'));
        return;
    }

    try {
        setButtonLoading(button, true, t('Đang cập nhật...'), t('Đặt lại mật khẩu'));

        const res = await fetch(`${API_BASE}/auth/admin/forgot-password/reset`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                sodienthoai: phone,
                otp,
                newPassword
            })
        });

        const data = await res.json();

        if (!data.success) {
            throw new Error(formatApiError(data, t('Đặt lại mật khẩu thất bại')));
        }

        document.getElementById('password').value = '';
        document.getElementById('sdt').value = phone;
        showLogin();
        showMessage('loginStatus', data.message || t('Đặt lại mật khẩu thành công, vui lòng đăng nhập lại'));
    } catch (err) {
        showError('forgotError', err.message);
    } finally {
        setButtonLoading(button, false, t('Đang cập nhật...'), t('Đặt lại mật khẩu'));
    }
}

document.addEventListener('DOMContentLoaded', () => {
    window.I18n?.init?.();

    const rememberedPhone = localStorage.getItem(REMEMBER_PHONE_KEY);
    if (rememberedPhone) {
        document.getElementById('sdt').value = rememberedPhone;
        document.getElementById('rememberLogin').checked = true;
    }
});
