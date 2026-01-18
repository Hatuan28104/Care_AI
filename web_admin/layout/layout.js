function loadHTML(id, file) {
  fetch(file)
    .then(res => res.text())
    .then(html => {
      document.getElementById(id).innerHTML = html;
      setActiveMenu();
    })
    .catch(err => console.error("Load error:", err));
}

function setActiveMenu() {
  const page = document.body.dataset.page;
  if (!page) return;

  document.querySelectorAll(".sidebar a").forEach(a => {
    if (a.dataset.page === page) {
      a.classList.add("active");
    }
  });
}
document.addEventListener("click", function (e) {
  const avatarBtn = document.getElementById("avatarBtn");
  const avatarMenu = document.getElementById("avatarMenu");

  if (!avatarBtn || !avatarMenu) return;

  // Click avatar -> toggle menu
  if (avatarBtn.contains(e.target)) {
    avatarMenu.classList.toggle("show");
    return;
  }

  // Click ngoài -> đóng menu
  if (!avatarMenu.contains(e.target)) {
    avatarMenu.classList.remove("show");
  }
});

// LOGOUT
document.addEventListener("click", function (e) {
  if (e.target.closest("#logoutBtn")) {
    // clear login state
    localStorage.removeItem("loggedIn");

    // redirect về login
    window.location.href = "../auth/auth.html";
  }
});

loadHTML("sidebar", "../layout/sidebar.html");
loadHTML("header", "../layout/header.html");
// load sidebar
fetch("/layout/sidebar.html")
  .then(res => res.text())
  .then(html => {
    document.getElementById("sidebar").innerHTML = html;
  });

// load header
fetch("/layout/header.html")
  .then(res => res.text())
  .then(html => {
    document.getElementById("header").innerHTML = html;

    // avatar dropdown
    const avatar = document.querySelector(".avatar");
    const menu = document.querySelector(".avatar-menu");

    if (avatar && menu) {
      avatar.addEventListener("click", () => {
        menu.classList.toggle("show");
      });
    }
  });
