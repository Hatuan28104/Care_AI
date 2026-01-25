document.addEventListener("DOMContentLoaded", () => {
  const page = document.body.dataset.page;
  let rowToDelete = null;

  /* ===============================
     LOAD SIDEBAR
     =============================== */
  fetch("../layout/sidebar.html")
    .then(res => res.text())
    .then(html => {
      const sidebar = document.getElementById("sidebar");
      if (sidebar) sidebar.innerHTML = html;
    });

  /* ===============================
     LOAD HEADER
     =============================== */
  fetch("../layout/header.html")
    .then(res => res.text())
    .then(html => {
      const header = document.getElementById("header");
      if (header) header.innerHTML = html;

      if (page === "service") {
        document.getElementById("btnAdd")?.addEventListener("click", () => {
          window.location.href = "./service-add.html";
        });
      }
    });

  /* ===============================
     SAVE FLOW (ADD + EDIT)
     =============================== */
  if (page === "service-add" || page === "service-edit") {
    const btnSave = document.getElementById("btnSave");
    const btnCancel = document.getElementById("btnCancel");

    const modal = document.getElementById("saveModal");
    const confirmSave = document.getElementById("confirmSave");
    const cancelSave = document.getElementById("cancelSave");
    const toast = document.getElementById("saveToast");

    btnSave?.addEventListener("click", () => {
      modal?.classList.remove("hidden");
    });

    btnCancel?.addEventListener("click", () => {
      window.location.href = "./service.html";
    });

    cancelSave?.addEventListener("click", () => {
      modal?.classList.add("hidden");
    });

    confirmSave?.addEventListener("click", () => {
      modal?.classList.add("hidden");
      toast?.classList.remove("hidden");

      setTimeout(() => {
        toast?.classList.add("hidden");
        window.location.href = "./service.html";
      }, 1800);
    });
  }

  /* ===============================
     ACTION MENU (LIST PAGE)
     =============================== */
  if (page === "service") {
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
        const menu = toggle.nextElementSibling;

        document.querySelectorAll(".action-menu").forEach(m => {
          if (m !== menu) m.style.display = "none";
        });

        menu.style.display = menu.style.display === "block" ? "none" : "block";
      });
    });

    document.addEventListener("click", e => {
      const item = e.target.closest(".action-item");
      if (!item) return;

      const row = item.closest("tr");
      const id = row?.dataset.id;

      if (item.dataset.action === "view") {
        window.location.href = `service-view.html?id=${id}`;
      }

      if (item.dataset.action === "edit") {
        window.location.href = `service-edit.html?id=${id}`;
      }

      if (item.dataset.action === "delete") {
        rowToDelete = row;
        document.getElementById("deleteModal")?.classList.remove("hidden");
      }
    });
  }

  /* ===============================
     DELETE CONFIRM (LIST + VIEW)
     =============================== */
  const deleteModal = document.getElementById("deleteModal");
  const confirmDelete = document.getElementById("confirmDelete");
  const cancelDelete = document.getElementById("cancelDelete");
  const toast = document.getElementById("saveToast");

  cancelDelete?.addEventListener("click", () => {
    deleteModal?.classList.add("hidden");
    rowToDelete = null;
  });

  confirmDelete?.addEventListener("click", () => {
    if (rowToDelete) rowToDelete.remove();

    deleteModal?.classList.add("hidden");
    toast?.classList.remove("hidden");

    setTimeout(() => {
      toast?.classList.add("hidden");
      window.location.href = "./service.html";
    }, 1500);
  });

  /* ===============================
     SERVICE VIEW PAGE
     =============================== */
  if (page === "service-view") {
    const id = new URLSearchParams(window.location.search).get("id");

    document.getElementById("btnEdit")?.addEventListener("click", () => {
      window.location.href = `service-edit.html?id=${id}`;
    });

    document.getElementById("btnDelete")?.addEventListener("click", () => {
      document.getElementById("deleteModal")?.classList.remove("hidden");
    });
  }
});
