const API_BASE = "http://localhost:3000";

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

          await fetch(`${API_BASE}/profile/${userId}`, {
            method: "DELETE"
          });

          rowToDelete.remove();
          showToast("Xoá thành công");

        } catch (err) {

          console.error(err);
          alert("Xóa thất bại");

        }

        rowToDelete = null;

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

      const form = new FormData();

      form.append("nguoiDungId", id);
      form.append("tenND", document.getElementById("tenND").value);
      form.append("ngaySinh", document.getElementById("ngaySinh").value);
      form.append("gioiTinh", document.getElementById("gioiTinh").value);
      form.append("chieuCao", document.getElementById("chieuCao").value);
      form.append("canNang", document.getElementById("canNang").value);
      form.append("email", document.getElementById("email").value);
      form.append("diaChi", document.getElementById("diaChi").value);

      const avatar = document.getElementById("avatarInput")?.files[0];
      if (avatar) {
        form.append("avatar", avatar);
      }

      const res = await fetch(`${API_BASE}/profile/update`, {
        method: "PUT",
        body: form
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

  tr.dataset.id = u.NguoiDung_ID;

  tr.innerHTML = `
    <td>${index + 1}</td>
    <td>${u.TenND ?? "(Chưa cập nhật)"}</td>
    <td>${u.SoDienThoai ?? "-"}</td>
    <td>${formatDate(u.NgaySinh)}</td>
    <td>${u.NgayTao ? formatDate(u.NgayTao) : "-"}</td>
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

if (u.AvatarUrl) {
  avatar.src = `${API_BASE}${u.AvatarUrl}`;
    } else {
      avatar.src =
        "https://cdn-icons-png.flaticon.com/512/149/149071.png";
    }
    document.getElementById("name").innerText = u.TenND ?? "-";
    const lastUpdate = u.NgayCapNhat || u.NgayTao;

    document.getElementById("updated").innerText =
      lastUpdate
        ? "Cập nhật lần cuối: " + formatDate(lastUpdate)
        : "-";
    document.getElementById("fullName").innerText = u.TenND ?? "-";
    document.getElementById("phone").innerText =
      u.SoDienThoai ?? "-";
    document.getElementById("dob").innerText =
      formatDate(u.NgaySinh);

    document.getElementById("gender").innerText =
      u.GioiTinh ? "Nam" : "Nữ";

    document.getElementById("height").innerText =
      u.ChieuCao ? `${u.ChieuCao} cm` : "-";

    document.getElementById("weight").innerText =
      u.CanNang ? `${u.CanNang} kg` : "-";

    document.getElementById("email").innerText =
      u.Email ?? "-";

    document.getElementById("address").innerText =
      u.DiaChi ?? "-";
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
    document.getElementById("tenND").value = u.TenND || "";
    document.getElementById("email").value = u.Email || "";
    document.getElementById("diaChi").value = u.DiaChi || "";
    document.getElementById("chieuCao").value = u.ChieuCao || "";
    document.getElementById("canNang").value = u.CanNang || "";
    document.getElementById("soDienThoai").value = u.SoDienThoai || "";

    // DATE
    if (u.NgaySinh) {
      const date = new Date(u.NgaySinh);
      document.getElementById("ngaySinh").value =
        date.toISOString().split("T")[0];
    }

    // GENDER
    document.getElementById("gioiTinh").value =
      u.GioiTinh ? "1" : "0";

    // AVATAR
    const avatar = document.getElementById("avatarPreview");

    if (avatar) {
      avatar.src = u.AvatarUrl
        ? `${API_BASE}${u.AvatarUrl}`
        : "https://cdn-icons-png.flaticon.com/512/149/149071.png";
    }

  } catch (err) {

    console.error("Load user edit error:", err);

  }

}