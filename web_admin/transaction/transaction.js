// ================================
// TRANSACTION SEARCH + FILTER
// ================================

document.addEventListener("DOMContentLoaded", () => {
  const searchInput = document.querySelector(".search input");
  const statusSelect = document.querySelector(".status-filter select");
  const rows = document.querySelectorAll("tbody tr");

  function filterTable() {
    const keyword = searchInput.value.toLowerCase();
    const selectedStatus = statusSelect.value.toLowerCase();

    rows.forEach(row => {
      const rowText = row.innerText.toLowerCase();
      const statusCell = row.querySelector(".status");
      const rowStatus = statusCell ? statusCell.innerText.toLowerCase() : "";

      const matchKeyword = rowText.includes(keyword);
      const matchStatus =
        selectedStatus === "filter by status" ||
        selectedStatus === "" ||
        rowStatus === selectedStatus;

      if (matchKeyword && matchStatus) {
        row.style.display = "";
      } else {
        row.style.display = "none";
      }
    });
  }

  // EVENTS
  searchInput.addEventListener("input", filterTable);
  statusSelect.addEventListener("change", filterTable);
});
