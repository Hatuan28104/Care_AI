function togglePassword() {
  const input = document.getElementById("password");
  const toggle = document.querySelector(".toggle i");

  const isHidden = input.type === "password";

  input.type = isHidden ? "text" : "password";

  toggle.className = isHidden
    ? "fa-solid fa-eye"
    : "fa-solid fa-eye-slash";

  toggle.parentElement.classList.toggle("active", isHidden);
}


function login() {
  const email = document.getElementById("email").value;
  const password = document.getElementById("password").value;

  if (email === "admin@example.com" && password === "admin123") {
    alert("Login success");
    window.location.href = "../dashboard/dashboard.html";
  } else {
    alert("Invalid credentials");
  }
}
