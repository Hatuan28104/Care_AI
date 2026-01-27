document.addEventListener("DOMContentLoaded", () => {
  const page = document.body.dataset.page;
  let rowToDelete = null;

  /* ===============================
     COMMON CONFIRM POPUPS
     =============================== */
  function confirmSave(onConfirm) {
    openModal({
      title: "Confirm Acceptance",
      desc: "Are you sure you want to save the modified information?",
      primaryText: "Confirm",
      primaryClass: "btn-save",
      onConfirm
    });
  }

  function confirmDelete(onConfirm) {
    openModal({
      title: "Confirm deletion",
      desc: "Are you sure you want to delete this Digital Human?",
      primaryText: "Delete",
      primaryClass: "btn-delete",
      onConfirm
    });
  }

  /* ===============================
     BACK (ADD + EDIT + VIEW)
     =============================== */
  if (
    page === "digital-add" ||
    page === "digital-edit" ||
    page === "digital-view"
  ) {
    document.getElementById("btnBack")?.addEventListener("click", () => {
      window.location.href = "./digital.html";
    });
  }

  /* ===============================
     ADD BUTTON (LIST PAGE)
     =============================== */
  if (page === "digital") {
    document.getElementById("btnAdd")?.addEventListener("click", () => {
      window.location.href = "./digital-add.html";
    });
  }

  /* ===============================
     SAVE (ADD + EDIT)
     =============================== */
  if (page === "digital-add" || page === "digital-edit") {
    document.getElementById("btnSave")?.addEventListener("click", () => {
      confirmSave(() => {
        showToast(
          page === "digital-add"
            ? "Added successfully"
            : "Updated successfully"
        );

        setTimeout(() => {
          window.location.href = "./digital.html";
        }, 1500);
      });
    });

    document.getElementById("btnCancel")?.addEventListener("click", () => {
      window.location.href = "./digital.html";
    });
  }

  /* ===============================
     ACTION MENU (LIST PAGE)
     =============================== */
  if (page === "digital") {
    const ACTIONS = [
      { key: "view", icon: "eye", label: "View" },
      { key: "edit", icon: "pen", label: "Edit" },
      { key: "delete", icon: "trash", label: "Delete" }
    ];

    document.querySelectorAll(".action-menu").forEach(menu => {
      menu.innerHTML = ACTIONS
        .map(
          a => `
          <div class="action-item" data-action="${a.key}">
            <i class="fa-solid fa-${a.icon}"></i>
            <span>${a.label}</span>
          </div>
        `
        )
        .join("");
    });

    document.querySelectorAll(".action-toggle").forEach(toggle => {
      toggle.addEventListener("click", e => {
        e.stopPropagation();
        const menu = toggle.nextElementSibling;

        document.querySelectorAll(".action-menu").forEach(m => {
          if (m !== menu) m.style.display = "none";
        });

        menu.style.display =
          menu.style.display === "block" ? "none" : "block";
      });
    });
  }

  /* ===============================
     ACTION CLICK (LIST PAGE)
     =============================== */
  document.addEventListener("click", e => {
    if (page !== "digital") return;

    const item = e.target.closest(".action-item");
    if (!item) return;

    const row = item.closest("tr");
    const id = row?.dataset.id;

    if (item.dataset.action === "view") {
      window.location.href = `digital-view.html?id=${id}`;
    }

    if (item.dataset.action === "edit") {
      window.location.href = `digital-edit.html?id=${id}`;
    }

    if (item.dataset.action === "delete") {
      rowToDelete = row;

      confirmDelete(() => {
        rowToDelete.remove();
        showToast("Deleted successfully");
      });
    }
  });

  /* ===============================
     VIEW PAGE
     =============================== */
  if (page === "digital-view") {
    const id = new URLSearchParams(window.location.search).get("id");

    document.getElementById("btnEdit")?.addEventListener("click", () => {
      window.location.href = `digital-edit.html?id=${id}`;
    });

    document.getElementById("btnDelete")?.addEventListener("click", () => {
      confirmDelete(() => {
        showToast("Deleted successfully");
        setTimeout(() => {
          window.location.href = "./digital.html";
        }, 1200);
      });
    });
  }
});
/* ===============================
   AVATAR UPLOAD (ADD + EDIT)
   =============================== */
const avatarBox = document.getElementById("avatarBox");
const avatarInput = document.getElementById("avatarInput");
const avatarPreview = document.getElementById("avatarPreview");
const uploadIcon = document.getElementById("uploadIcon");
const uploadText = document.getElementById("uploadText");
const btnRemoveAvatar = document.getElementById("btnRemoveAvatar");

if (avatarBox && avatarInput) {
  // click avatar → mở file
  avatarBox.addEventListener("click", () => {
    avatarInput.click();
  });

  // chọn file → preview
  avatarInput.addEventListener("change", () => {
    const file = avatarInput.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = e => {
      avatarPreview.src = e.target.result;
      avatarPreview.classList.remove("hidden");

      uploadIcon?.classList.add("hidden");
      uploadText?.classList.add("hidden");

      btnRemoveAvatar?.classList.remove("hidden");
    };
    reader.readAsDataURL(file);
  });
}

// REMOVE AVATAR (EDIT ONLY)
btnRemoveAvatar?.addEventListener("click", e => {
  e.stopPropagation();

  avatarInput.value = "";
  avatarPreview.src = "";
  avatarPreview.classList.add("hidden");

  uploadIcon?.classList.remove("hidden");
  uploadText?.classList.remove("hidden");

  btnRemoveAvatar.classList.add("hidden");
});
