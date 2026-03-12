function togglePassword() {
  const input = document.getElementById("password");
  const icon = document.querySelector(".toggle i");

  const isHidden = input.type === "password";

  input.type = isHidden ? "text" : "password";
  icon.className = isHidden
    ? "fa-solid fa-eye"
    : "fa-solid fa-eye-slash";
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

  toast.querySelector("span").innerText = "Đăng nhập thành công";
  toast.querySelector("i").style.background = "#16A34A";
  toast.classList.remove("hidden");

  setTimeout(() => {
    window.location.href = "../dashboard/dashboard.html";
  }, 1200);
}
