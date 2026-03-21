
export const API_BASE = "https://care-ai-fb8q.onrender.com";

function toAbsoluteImageUrl(path) {
  if (!path) return "https://cdn-icons-png.flaticon.com/512/149/149071.png";
  if (/^https?:\/\//i.test(path)) return path;
  const cleanPath = path.startsWith("/") ? path : `/${path}`;
  return `${API_BASE}${cleanPath}`;
}
document.addEventListener("DOMContentLoaded", () => {

  const page = document.body.dataset.page;
  let rowToDelete = null;

  /* ==========================
     LOAD USERS
  ========================== */
  if (page === "user") {
    loadUsers();
  }

  /* ==========================
     CONFIRM POPUPS
  ========================== */
  function confirmUserSave(onConfirm) {
    openModal({
      title: "Xác nhận lưu",
      desc: "Bạn có chắc chắn muốn lưu các thay đổi này không?",
      primaryText: "Xác nhận",
      primaryClass: "btn-save",
      onConfirm
    });
  }

  function confirmUserDelete(onConfirm) {
    openModal({
      title: "Xác nhận xoá",
      desc: "Bạn có chắc chắn muốn xoá người dùng này không?",
      primaryText: "Xoá",
      primaryClass: "btn-delete",
      onConfirm
    });
  }

  /* ==========================
     SEARCH USERS
  ========================== */
  const searchInput = document.querySelector(".search input");

  if (searchInput) {

    searchInput.addEventListener("input", () => {

      const keyword = searchInput.value.toLowerCase();

      document.querySelectorAll("#userTable tr").forEach(row => {

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
     ACTION CLICK
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

      confirmUserDelete(async () => {

        try {

          const res = await fetch(`${API_BASE}/profile/${userId}`, {
            method: "DELETE"
          });

          const json = await res.json();

          if (!json.success) {
            alert(json.message || "Xóa thất bại");
            return;
          }

          rowToDelete.remove();
          showToast("Xoá thành công");

        } catch (err) {

          console.error(err);
          alert("Lỗi kết nối server");

        } finally {
          rowToDelete = null;
        }

      });

    }

  });

  /* ==========================
     DELETE DETAIL PAGE
  ========================== */
if (page === "user-detail") {

  const params = new URLSearchParams(window.location.search);
  const id = params.get("id");

  loadUserDetail(id);

  document.querySelector(".btn-delete")?.addEventListener("click", () => {

    confirmUserDelete(async () => {

      await fetch(`${API_BASE}/profile/${id}`, {
        method: "DELETE"
      });

      showToast("Xoá thành công");

      setTimeout(() => {
        window.location.href = "./user.html";
      }, 1200);

    });

  });

}

  /* ==========================
     EDIT PAGE
  ========================== */
  if (page === "user-edit") {
    const params = new URLSearchParams(window.location.search);
const id = params.get("id");

loadUserEdit(id);
document.querySelector(".btn-save")?.addEventListener("click", () => {

  confirmUserSave(async () => {

    try {

      const avatarInput = document.getElementById("avatarInput");

      const formData = new FormData();

      formData.append("tenND", document.getElementById("tenND").value);
      formData.append("ngaySinh", document.getElementById("ngaySinh").value);
      formData.append("gioiTinh", document.getElementById("gioiTinh").value);
      formData.append("chieuCao", document.getElementById("chieuCao").value);
      formData.append("canNang", document.getElementById("canNang").value);
      formData.append("email", document.getElementById("email").value);
      formData.append("diaChi", document.getElementById("diaChi").value);

      // 👇 upload avatar nếu có
      if (avatarInput.files[0]) {
        formData.append("avatar", avatarInput.files[0]);
      }

      const res = await fetch(`${API_BASE}/profile/${id}`, {
        method: "PUT",
        body: formData
      });

      const json = await res.json();

      if (!json.success) {
        alert(json.message || "Cập nhật thất bại");
        return;
      }

      showToast("Cập nhật thành công");

      setTimeout(() => {
        window.location.href = "./user.html";
      }, 1200);

    } catch (err) {
      console.error(err);
      alert("Lỗi kết nối server");
    }

  });

});
    document.querySelector(".btn-cancel")?.addEventListener("click", () => {
      window.location.href = "./user.html";
    });

    const input = document.getElementById("avatarInput");
    const preview = document.getElementById("avatarPreview");
    const btnChange = document.getElementById("btnChangeAvatar");

    btnChange?.addEventListener("click", () => {
      input.click();
    });

    input?.addEventListener("change", () => {

      const file = input.files[0];
      if (!file) return;

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
     CLOSE MENU
  ========================== */
  document.addEventListener("click", () => {

    document.querySelectorAll(".action-menu").forEach(menu => {
      menu.style.display = "none";
    });

  });

});

/* ==========================
   LOAD USERS API
========================== */
async function loadUsers() {

  try {

    const res = await fetch(`${API_BASE}/profile`);
    const json = await res.json();

    const users = json.data || [];
    const tbody = document.getElementById("userTable");

    if (!tbody) return;

    tbody.innerHTML = "";

    users.forEach((u, index) => {

      const tr = document.createElement("tr");

      tr.dataset.id = u.nguoiDungId;

      tr.innerHTML = `
        <td>${index + 1}</td>
        <td>${u.tenND ?? "(Chưa cập nhật)"}</td>
        <td>${u.soDienThoai ?? "-"}</td>
        <td>${formatDate(u.ngaySinh)}</td>
        <td>${u.ngayTao ? formatDate(u.ngayTao) : "-"}</td>
        <td class="actions">
          <i class="fa-solid fa-ellipsis-vertical action-toggle"></i>
          <div class="action-menu"></div>
        </td>
      `;

      tbody.appendChild(tr);

    });

    initActionMenus();

  } catch (err) {

    console.error("Load users error:", err);

  }

}
async function loadUserDetail(id){

  try{

    const res = await fetch(`${API_BASE}/profile/${id}`);
    const json = await res.json();
    const u = json.data;

    if(!u) return;
    const avatar = document.getElementById("avatar");

    avatar.src = toAbsoluteImageUrl(u.avatarUrl);

    document.getElementById("name").innerText = u.tenND ?? "-";

    const lastUpdate = u.ngayCapNhat || u.ngayTao;

    document.getElementById("updated").innerText =
      lastUpdate
        ? "Cập nhật lần cuối: " + formatDate(lastUpdate)
        : "-";

    document.getElementById("fullName").innerText = u.tenND ?? "-";
    document.getElementById("phone").innerText = u.soDienThoai ?? "-";

    document.getElementById("dob").innerText =
      formatDate(u.ngaySinh);

    document.getElementById("gender").innerText =
      u.gioiTinh ? "Nam" : "Nữ";

    document.getElementById("height").innerText =
      u.chieuCao ? `${u.chieuCao} cm` : "-";

    document.getElementById("weight").innerText =
      u.canNang ? `${u.canNang} kg` : "-";

    document.getElementById("email").innerText =
      u.email ?? "-";

    document.getElementById("address").innerText =
      u.diaChi ?? "-";

    document.getElementById("editBtn").href =
      `./user-edit.html?id=${id}`;
    }
  catch(e){
    console.error(e);
  }

}
/* ==========================
   FORMAT DATE
========================== */
function formatDate(dateStr) {
  if (!dateStr) return "-";

  const d = new Date(dateStr);
  if (isNaN(d)) return "-";

  return d.toLocaleDateString("vi-VN");
}

/* ==========================
   INIT ACTION MENU
========================== */
function initActionMenus() {

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

      document.querySelectorAll(".action-menu").forEach(m => {
        if (m !== toggle.nextElementSibling) {
          m.style.display = "none";
        }
      });

      const menu = toggle.nextElementSibling;

      menu.style.display =
        menu.style.display === "block"
          ? "none"
          : "block";

    });

  });

}
async function loadUserEdit(id) {

  try {

    const res = await fetch(`${API_BASE}/profile/${id}`);
    const json = await res.json();
    const u = json.data;
console.log("User data:", u);
    if (!u) return;

    // TEXT INPUT
    document.getElementById("tenND").value = u.tenND || "";
    document.getElementById("email").value = u.email || "";
    document.getElementById("diaChi").value = u.diaChi || "";
    document.getElementById("chieuCao").value = u.chieuCao || "";
    document.getElementById("canNang").value = u.canNang || "";
    document.getElementById("soDienThoai").value = u.soDienThoai || "";

    if (u.ngaySinh) {
      const date = new Date(u.ngaySinh);
      document.getElementById("ngaySinh").value =
        date.toISOString().split("T")[0];
    }

    document.getElementById("gioiTinh").value =
      u.gioiTinh ? "1" : "0";

    const avatar = document.getElementById("avatarPreview");

    if (avatar) {
      avatar.src = toAbsoluteImageUrl(u.avatarUrl);
    }

  } catch (err) {

    console.error("Load user edit error:", err);

  }

}
