document.addEventListener("DOMContentLoaded", () => {
  const page = document.body.dataset.page;
  let rowToDelete = null;

  /* ===============================
     COMMON CONFIRM POPUPS
     =============================== */
  function confirmServiceSave(onConfirm) {
    openModal({
      title: "Confirm acceptance",
      desc: "Are you sure you want to save this service?",
      primaryText: "Confirm",
      primaryClass: "btn-save",
      onConfirm
    });
  }

  function confirmServiceDelete(onConfirm) {
    openModal({
      title: "Confirm deletion",
      desc: "Are you sure you want to delete this service?",
      primaryText: "Delete",
      primaryClass: "btn-delete",
      onConfirm
    });
  }
/* ===============================
   ADD BUTTON (LIST PAGE)
   =============================== */
if (page === "service") {
  document.getElementById("btnAdd")?.addEventListener("click", () => {
    window.location.href = "./service-add.html";
  });
}

  /* ===============================
     SAVE (ADD + EDIT)
     =============================== */
  if (page === "service-add" || page === "service-edit") {
    document.getElementById("btnSave")?.addEventListener("click", () => {
      confirmServiceSave(() => {
        showToast(
          page === "service-add"
            ? "Added successfully"
            : "Updated successfully"
        );

        setTimeout(() => {
          window.location.href = "./service.html";
        }, 1500);
      });
    });

    document.getElementById("btnCancel")?.addEventListener("click", () => {
      window.location.href = "./service.html";
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

        document.querySelectorAll(".action-menu").forEach(m => {
          if (m !== toggle.nextElementSibling) m.style.display = "none";
        });

        const menu = toggle.nextElementSibling;
        menu.style.display =
          menu.style.display === "block" ? "none" : "block";
      });
    });
  }

  /* ===============================
     ACTION CLICK (LIST PAGE)
     =============================== */
  document.addEventListener("click", e => {
    if (page !== "service") return;

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

      confirmServiceDelete(() => {
        rowToDelete.remove();
        showToast("Deleted successfully");
        rowToDelete = null;
      });
    }
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
      confirmServiceDelete(() => {
        showToast("Deleted successfully");
        setTimeout(() => {
          window.location.href = "./service.html";
        }, 1200);
      });
    });
  }

  /* ===============================
     CLICK OUTSIDE → CLOSE ACTION MENU
     =============================== */
  document.addEventListener("click", () => {
    document.querySelectorAll(".action-menu").forEach(m => {
      m.style.display = "none";
    });
  });
});
