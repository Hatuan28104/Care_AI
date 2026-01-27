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

  const toast = document.getElementById("loginToast");

  if (email === "admin@example.com" && password === "admin123") {
    localStorage.setItem("loggedIn", "true");

    // show toast success
    toast.querySelector("span").innerText = "Đăng nhập thành công";
    toast.querySelector("i").style.background = "#16A34A";
    toast.classList.remove("hidden");

    // redirect sau 1.2s
    setTimeout(() => {
      window.location.href = "../dashboard/dashboard.html";
    }, 1200);

  } else {
    // toast lỗi
    toast.querySelector("span").innerText = "Email hoặc mật khẩu không đúng";
    toast.querySelector("i").style.background = "#EF4444";
    toast.classList.remove("hidden");

    setTimeout(() => {
      toast.classList.add("hidden");
    }, 1500);
  }
}
