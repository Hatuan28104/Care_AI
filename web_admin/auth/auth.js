function togglePassword() {
  const input = document.getElementById("password");
  const icon = document.querySelector(".toggle i");

  const isHidden = input.type === "password";

  // đổi type
  input.type = isHidden ? "text" : "password";

  // đổi icon cho ĐÚNG logic
  icon.className = isHidden
    ? "fa-solid fa-eye"
    : "fa-solid fa-eye-slash";
}

function login() {
  const email = document.getElementById("email").value.trim();
  const password = document.getElementById("password").value.trim();

  if (email === "admin@example.com" && password === "admin123") {
        localStorage.setItem("loggedIn", "true");

    alert("Login success");

    // chuyển sang dashboard
    window.location.href = "../dashboard/dashboard.html";
  } else {
    alert("Invalid credentials");
  }
}
