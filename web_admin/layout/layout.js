/* ===============================
   LOAD HTML HELPER
   =============================== */
function loadHTML(id, file, callback) {
  fetch(file)
    .then(res => res.text())
    .then(html => {
      const el = document.getElementById(id);
      if (!el) return;
      el.innerHTML = html;
      callback && callback();
    })
    .catch(err => console.error("Load error:", err));
}

/* ===============================
   LOAD LAYOUT PARTS
   =============================== */
loadHTML("sidebar", "../layout/sidebar.html", setActiveMenu);
loadHTML("header", "../layout/header.html", initAvatar);
loadHTML("popup", "../layout/popup.html");

/* ===============================
   ACTIVE MENU
   =============================== */
function setActiveMenu() {
  const page = document.body.dataset.page;
  if (!page) return;

  document.querySelectorAll(".sidebar a").forEach(a => {
    a.classList.toggle("active", a.dataset.page === page);
  });
}

/* ===============================
   AVATAR DROPDOWN
   =============================== */
function initAvatar() {
  const avatar = document.querySelector(".avatar");
  const menu = document.querySelector(".avatar-menu");
  if (!avatar || !menu) return;

  avatar.addEventListener("click", e => {
    e.stopPropagation();
    menu.classList.toggle("show");
  });

  document.addEventListener("click", () => {
    menu.classList.remove("show");
  });
}

/* ===============================
   LOGOUT
   =============================== */
document.addEventListener("click", e => {
  if (e.target.closest("#logoutBtn")) {
    localStorage.removeItem("loggedIn");
    window.location.href = "../auth/auth.html";
  }
});

/* ===============================
   GLOBAL MODAL API
   =============================== */
window.openModal = function ({
  title,
  desc,
  primaryText = "Confirm",
  primaryClass = "btn-delete",
  onConfirm
}) {
  const modal = document.getElementById("confirmModal");
  if (!modal) return;

  const titleEl = document.getElementById("modalTitle");
  const descEl = document.getElementById("modalDesc");
  const confirmBtn = document.getElementById("modalConfirm");
  const cancelBtn = document.getElementById("modalCancel");

  titleEl.innerText = title;
  descEl.innerText = desc;

  confirmBtn.innerText = primaryText;
  confirmBtn.className = "";          // reset class
  confirmBtn.classList.add(primaryClass);

  modal.classList.remove("hidden");

  const close = () => modal.classList.add("hidden");

  confirmBtn.onclick = () => {
    close();
    onConfirm && onConfirm();
  };

  cancelBtn.onclick = close;
document.addEventListener("click", e => {
  if (e.target.classList.contains("modal-close")) {
    e.target.closest(".modal").classList.add("hidden");
  }
});
document.addEventListener("click", e => {
  if (e.target.classList.contains("modal")) {
    e.target.classList.add("hidden");
  }
});

};
/* ===============================
   TOAST
   =============================== */
window.showToast = function (text) {
  const toast = document.getElementById("toast");
  if (!toast) return;

  document.getElementById("toastText").innerText = text;
  toast.classList.remove("hidden");

  setTimeout(() => toast.classList.add("hidden"), 1500);
};
