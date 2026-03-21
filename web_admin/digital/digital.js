export const API_BASE = "https://care-ai-fb8q.onrender.com";

const API = `${API_BASE}/api/digital-human`;

function toAbsoluteImageUrl(path) {
  if (!path) return "https://cdn-icons-png.flaticon.com/512/149/149071.png";
  if (/^https?:\/\//i.test(path)) return path;
  const cleanPath = path.startsWith("/") ? path : `/${path}`;
  return `${API_BASE}${cleanPath}`;
}

function toStoredImagePath(urlOrPath) {
  if (!urlOrPath) return "";
  if (/^https?:\/\//i.test(urlOrPath)) {
    return urlOrPath.replace(`${API_BASE}/`, "").replace(`${API_BASE}`, "");
  }
  return urlOrPath.startsWith("/") ? urlOrPath.slice(1) : urlOrPath;
}
document.addEventListener("DOMContentLoaded", () => {

  const page = document.body.dataset.page;
  let rowToDelete = null;

  /* ===============================
     LOAD DIGITAL HUMAN LIST
  =============================== */
  if (page === "digital") {
    loadDigital();
  }

  async function loadDigital() {
    try {

      const res = await fetch(API);
      const result = await res.json();

      const tbody = document.querySelector("tbody");
      if (!tbody) return;

      tbody.innerHTML = "";

      result.data.forEach(d => {

        const gender = d.gioitinh ? "Nam" : "Nữ";

      const avatar = toAbsoluteImageUrl(d.imageurl);

        const row = `
          <tr data-id="${d.digitalhuman_id}">
            <td>${d.digitalhuman_id}</td>
            <td>${d.tendigitalhuman}</td>
            <td>
              <img src="${avatar}" class="avatar" />
            </td>
            <td>${gender}</td>
            <td class="actions">
              <i class="fa-solid fa-ellipsis-vertical action-toggle"></i>
              <div class="action-menu"></div>
            </td>
          </tr>
        `;

        tbody.innerHTML += row;

      });

      initActionMenu();

    } catch (err) {
      console.error(err);
    }
  }

  /* ===============================
     COMMON CONFIRM POPUPS
  =============================== */

  function confirmSave(onConfirm) {
    openModal({
      title: "Xác nhận lưu",
      desc: "Bạn có chắc chắn muốn lưu các thay đổi này không?",
      primaryText: "Xác nhận",
      primaryClass: "btn-save",
      onConfirm
    });
  }

  function confirmDelete(onConfirm) {
    openModal({
      title: "Xác nhận xoá",
      desc: "Bạn có chắc chắn muốn xoá nhân sự số này không?",
      primaryText: "Xoá",
      primaryClass: "btn-delete",
      onConfirm
    });
  }

  /* ===============================
     BACK BUTTON
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
     ADD BUTTON
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

    const digitalId = document.getElementById("digitalId");
    const digitalName = document.getElementById("digitalName");
    const gender = document.getElementById("gender");
    const jobId = document.getElementById("jobId");
    const appearance = document.getElementById("appearance");
    const systemPrompt = document.getElementById("systemPrompt");

    if (page === "digital-edit") {

      const id = new URLSearchParams(window.location.search).get("id");

      fetch(`${API}/${id}`)
        .then(res => res.json())
        .then(json => {

          const d = json.data;
          if (!d) return;

          digitalId.value = d.digitalhuman_id;
          digitalId.disabled = true;

          digitalName.value = d.tendigitalhuman || "";
          gender.value = d.gioitinh ? "1" : "0";
          jobId.value = (d.nghenghiep_id || "").trim();
          appearance.value = d.ngoaihinh || "";
          systemPrompt.value = d.systemprompt || "";

          if (d.imageurl && avatarPreview) {
            avatarPreview.src = toAbsoluteImageUrl(d.imageurl);
            avatarPreview.classList.remove("hidden");
          }

        });

    }

    document.getElementById("btnSave")?.addEventListener("click", () => {

      confirmSave(async () => {

        const form = new FormData();

        form.append("id", digitalId?.value || "");
        form.append("name", digitalName?.value || "");
        form.append("gender", gender?.value || "");
        form.append("jobId", jobId?.value || "");
        form.append("appearance", appearance?.value || "");
        form.append("prompt", systemPrompt?.value || "");

        const file = avatarInput?.files?.[0];

        if (file) {
          form.append("avatar", file);
        } else if (avatarPreview?.src) {
          form.append(
            "image",
            toStoredImagePath(avatarPreview.src)
          );
        }

        try {

          if (page === "digital-add") {

            const res = await fetch(API, {
              method: "POST",
              body: form
            });

            const json = await res.json();

            if (!json.success) {
              alert(json.message || "Thêm thất bại");
              return;
            }

          }

          if (page === "digital-edit") {

            const id = new URLSearchParams(window.location.search).get("id");

            await fetch(`${API}/${id}`, {
              method: "PUT",
              body: form
            });

          }

          showToast(
            page === "digital-add"
              ? "Thêm thành công"
              : "Cập nhật thành công"
          );

          setTimeout(() => {
            window.location.href = "./digital.html";
          }, 1200);

        } catch (err) {
          console.error(err);
        }

      });

    });

    document.getElementById("btnCancel")?.addEventListener("click", () => {
      window.location.href = "./digital.html";
    });

  }

  /* ===============================
     ACTION MENU
  =============================== */

  function initActionMenu() {

    const ACTIONS = [
      { key: "view", icon: "eye", label: "Xem" },
      { key: "edit", icon: "pen", label: "Chỉnh sửa" },
      { key: "delete", icon: "trash", label: "Xoá" }
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

        menu.style.display =
          menu.style.display === "block" ? "none" : "block";

      });

    });

  }

  document.addEventListener("click", async e => {

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

      confirmDelete(async () => {

        await fetch(`${API}/${id}`, {
          method: "DELETE"
        });

        rowToDelete.remove();
        showToast("Xoá thành công");

      });

    }

  });

  if (page === "digital-view") {

    const id = new URLSearchParams(window.location.search).get("id");

    loadDigitalDetail(id);

  }

  async function loadDigitalDetail(id) {

    try {

      const res = await fetch(`${API}/${id}`);
      const json = await res.json();
      const d = json.data;

      if (!d) return;

      document.getElementById("digitalTitle").innerText = d.tendigitalhuman;
      document.getElementById("digitalId").innerText = d.digitalhuman_id;
      document.getElementById("digitalName").innerText = d.tendigitalhuman;

      document.getElementById("digitalGender").innerText =
        d.gioitinh ? "Nam" : "Nữ";

      document.getElementById("digitalJob").innerText =
        d.nghenghiep_id || "-";

      document.getElementById("digitalAppearance").innerText =
        d.ngoaihinh || "-";

      document.getElementById("digitalPrompt").innerText =
        d.systemprompt || "-";

      const avatar = document.getElementById("digitalAvatar");

    avatar.src = toAbsoluteImageUrl(d.imageurl);

    } catch (err) {
      console.error(err);
    }

  }

});

/* ===============================
   AVATAR UPLOAD
=============================== */

const avatarBox = document.getElementById("avatarBox");
const avatarInput = document.getElementById("avatarInput");
const avatarPreview = document.getElementById("avatarPreview");
const uploadIcon = document.getElementById("uploadIcon");
const uploadText = document.getElementById("uploadText");
const btnRemoveAvatar = document.getElementById("btnRemoveAvatar");

if (avatarBox && avatarInput) {

  avatarBox.addEventListener("click", () => {
    avatarInput.click();
  });

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

btnRemoveAvatar?.addEventListener("click", e => {

  e.stopPropagation();

  avatarInput.value = "";
  avatarPreview.src = "";
  avatarPreview.classList.add("hidden");

  uploadIcon?.classList.remove("hidden");
  uploadText?.classList.remove("hidden");

  btnRemoveAvatar.classList.add("hidden");

});
