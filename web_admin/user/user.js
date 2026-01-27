document.addEventListener("DOMContentLoaded", () => {
  const page = document.body.dataset.page;
  let rowToDelete = null;

  /* ==========================
     COMMON CONFIRM POPUPS
     ========================== */
  function confirmUserSave(onConfirm) {
    openModal({
      title: "Confirm acceptance",
      desc: "Are you sure you want to save the modified information?",
      primaryText: "Confirm",
      primaryClass: "btn-save",
      onConfirm
    });
  }

  function confirmUserDelete(onConfirm) {
    openModal({
      title: "Confirm deletion",
      desc: "Are you sure you want to delete this user?",
      primaryText: "Delete",
      primaryClass: "btn-delete",
      onConfirm
    });
  }

  /* ==========================
     SEARCH USERS (LIST PAGE)
     ========================== */
  const searchInput = document.querySelector(".search input");
  if (searchInput) {
    searchInput.addEventListener("input", () => {
      const keyword = searchInput.value.toLowerCase();
      document.querySelectorAll("tbody tr").forEach(row => {
        const name = row.children[1]?.innerText.toLowerCase() || "";
        const phone = row.children[2]?.innerText.toLowerCase() || "";
        row.style.display =
          name.includes(keyword) || phone.includes(keyword) ? "" : "none";
      });
    });
  }

  /* ==========================
     ACTION MENU (LIST PAGE)
     ========================== */
  if (page === "user") {
    const ACTIONS = [
      { key: "view", icon: "eye", label: "View" },
      { key: "edit", icon: "pen", label: "Edit" },
      { key: "delete", icon: "trash", label: "Delete" }
    ];

    document.querySelectorAll(".action-menu").forEach(menu => {
      menu.innerHTML = ACTIONS.map(a => `
        <div class="action-item" data-action="${a.key}">
          <i class="fa-solid fa-${a.icon}"></i>
          <span>${a.label}</span>
        </div>
      `).join("");
    });

    document.querySelectorAll(".action-toggle").forEach(toggle => {
      toggle.addEventListener("click", e => {
        e.stopPropagation();

        document.querySelectorAll(".action-menu").forEach(m => {
          if (m !== toggle.nextElementSibling) m.style.display = "none";
        });

        const menu = toggle.nextElementSibling;
        menu.style.display =
          menu.style.display === "block" ? "none" : "block";
      });
    });
  }

  /* ==========================
     ACTION CLICK (LIST PAGE)
     ========================== */
  document.addEventListener("click", e => {
    if (page !== "user") return;

    const item = e.target.closest(".action-item");
    if (!item) return;

    const action = item.dataset.action;
    const row = item.closest("tr");
    const userId = row?.dataset.id;

    if (action === "view") {
      window.location.href = `user-detail.html?id=${userId}`;
    }

    if (action === "edit") {
      window.location.href = `user-edit.html?id=${userId}`;
    }

    if (action === "delete") {
      rowToDelete = row;
      confirmUserDelete(() => {
        rowToDelete.remove();
        showToast("Deleted successfully");
        rowToDelete = null;
      });
    }
  });

  /* ==========================
     DELETE (DETAIL PAGE)
     ========================== */
  if (page === "user-detail") {
    document.querySelector(".btn-delete")?.addEventListener("click", () => {
      confirmUserDelete(() => {
        showToast("Deleted successfully");
        setTimeout(() => {
          window.location.href = "./user.html";
        }, 1200);
      });
    });
  }

  /* ==========================
     SAVE (EDIT PAGE)
     ========================== */
  if (page === "user-edit") {
    document.querySelector(".btn-save")?.addEventListener("click", () => {
      confirmUserSave(() => {
        showToast("Updated successfully");
        setTimeout(() => {
          window.location.href = "./user.html";
        }, 1500);
      });
    });

    document.querySelector(".btn-cancel")?.addEventListener("click", () => {
      window.location.href = "./user.html";
    });
  const input = document.getElementById("avatarInput");
  const preview = document.getElementById("avatarPreview");
  const btnChange = document.getElementById("btnChangeAvatar");

  // bấm Change avatar → mở file
  btnChange?.addEventListener("click", () => {
    input.click();
  });

  // chọn file → preview ảnh
  input?.addEventListener("change", () => {
    const file = input.files[0];
    if (!file) return;

    // chỉ cho phép ảnh
    if (!file.type.startsWith("image/")) {
      alert("Vui lòng chọn file ảnh");
      input.value = "";
      return;
    }

    const reader = new FileReader();
    reader.onload = e => {
      preview.src = e.target.result;
    };
    reader.readAsDataURL(file);
  });
  }

  /* ==========================
     CLICK OUTSIDE → CLOSE MENU
     ========================== */
  document.addEventListener("click", () => {
    document.querySelectorAll(".action-menu").forEach(m => {
      m.style.display = "none";
    });
  });
});
