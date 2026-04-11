function togglePassword() {
    const input = document.getElementById("password");
    const icon = document.getElementById("eyeIcon");

    const isHidden = input.type === "password";
    input.type = isHidden ? "text" : "password";

    if (icon) {
        icon.setAttribute('data-lucide', isHidden ? 'eye' : 'eye-off');
        if (window.lucide) lucide.createIcons();
    }
}

function login() {
    const email = document.getElementById("email").value.trim();
    const password = document.getElementById("password").value.trim();
    const error = document.getElementById("loginError");
    const toast = document.getElementById("loginToast");

    error.style.display = "none";

    // chưa nhập
    if (!email || !password) {
        error.innerText = "Vui lòng nhập email và mật khẩu";
        error.style.display = "block";
        return;
    }

    // sai tài khoản
    if (email !== "admin@example.com" || password !== "admin123") {
        error.innerText = "Email hoặc mật khẩu không đúng";
        error.style.display = "block";
        return;
    }

    // đăng nhập thành công
    localStorage.setItem("loggedIn", "true");

    setTimeout(() => {
        window.location.href = "../dashboard/dashboard.html";
    }, 1200);
}
