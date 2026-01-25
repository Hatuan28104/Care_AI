document.addEventListener("DOMContentLoaded", () => {

  /* ==========================
     0. SEARCH USERS (LIST PAGE)
     ========================== */
  const searchInput = document.querySelector(".search input");

  if (searchInput) {
    searchInput.addEventListener("input", () => {
      const keyword = searchInput.value.toLowerCase();
      const rows = document.querySelectorAll("tbody tr");

      rows.forEach(row => {
        const name = row.children[1]?.innerText.toLowerCase() || "";
        const phone = row.children[2]?.innerText.toLowerCase() || "";

        row.style.display =
          name.includes(keyword) || phone.includes(keyword)
            ? ""
            : "none";
      });
    });
  }

  /* ==========================
     1. ACTION MENU (LIST PAGE)
     ========================== */
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

  let rowToDelete = null;

  document.querySelectorAll(".action-toggle").forEach(toggle => {
    toggle.addEventListener("click", e => {
      e.stopPropagation();

      document.querySelectorAll(".action-menu").forEach(m => {
        if (m !== toggle.nextElementSibling) m.style.display = "none";
      });

      const menu = toggle.nextElementSibling;
      menu.style.display = menu.style.display === "block" ? "none" : "block";
    });
  });

  document.addEventListener("click", e => {
    const item = e.target.closest(".action-item");
    if (!item) return;

    e.stopPropagation();

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
      document.getElementById("deleteModal")?.classList.remove("hidden");
    }
  });

  /* ==========================
     2. DELETE – LIST & DETAIL
     ========================== */
  const modal = document.getElementById("deleteModal");
  const confirmBtn = document.getElementById("confirmDelete");
  const cancelBtn = document.getElementById("cancelDelete");
  const toast = document.getElementById("toast");

  if (modal && confirmBtn && cancelBtn && toast) {

    // Cancel
    cancelBtn.addEventListener("click", () => {
      modal.classList.add("hidden");
      rowToDelete = null;
    });

    // Confirm delete
    confirmBtn.addEventListener("click", () => {
      modal.classList.add("hidden");

      // Nếu là list page → xóa row
      if (rowToDelete) {
        rowToDelete.remove();
        rowToDelete = null;
      }

      toast.classList.remove("hidden");

      setTimeout(() => {
        toast.classList.add("hidden");

        // Nếu đang ở detail page → quay về users
        if (!document.querySelector(".action-menu")) {
          window.location.href = "./user.html";
        }
      }, 1500);
    });
  }

  /* ==========================
     3. DELETE BUTTON (DETAIL)
     ========================== */
  const detailDeleteBtn = document.querySelector(".detail-header .btn-delete");

  if (detailDeleteBtn && modal) {
    detailDeleteBtn.addEventListener("click", () => {
      modal.classList.remove("hidden");
    });
  }

  /* ==========================
     4. CLICK NGOÀI → ĐÓNG MENU
     ========================== */
  document.addEventListener("click", () => {
    document.querySelectorAll(".action-menu").forEach(m => {
      m.style.display = "none";
    });
  });

});
/* ==========================
   SAVE – USER EDIT PAGE
   ========================== */
document.addEventListener("DOMContentLoaded", () => {
  const saveBtn = document.querySelector(".btn-save");
  const saveModal = document.getElementById("saveModal");
  const confirmSave = document.getElementById("confirmSave");
  const cancelSave = document.getElementById("cancelSave");
  const toast = document.getElementById("saveToast");

  if (!saveBtn) return;

  saveBtn.addEventListener("click", () => {
    saveModal.classList.remove("hidden");
  });

  cancelSave.addEventListener("click", () => {
    saveModal.classList.add("hidden");
  });

  confirmSave.addEventListener("click", () => {
    saveModal.classList.add("hidden");

    // show toast
    toast.classList.remove("hidden");

    // sau 1.5s quay về users
    setTimeout(() => {
      window.location.href = "./user.html";
    }, 1500);
  });
});

document.addEventListener("DOMContentLoaded", () => {
  const cancelBtn = document.querySelector(".btn-cancel");

  if (cancelBtn) {
    cancelBtn.addEventListener("click", () => {
      window.location.href = "./user.html";
    });
  }
});
