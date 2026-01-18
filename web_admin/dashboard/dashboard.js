const tabs = document.querySelectorAll(".tabs button:not(.export)");

tabs.forEach(tab => {
  tab.addEventListener("click", () => {
    tabs.forEach(t => t.classList.remove("active"));
    tab.classList.add("active");

    document.querySelector(".chart-placeholder p").innerText =
      tab.innerText + " chart here";
  });
});

// ===== EXPORT TOAST =====
const exportBtn = document.querySelector(".tabs .export");
const toast = document.getElementById("toast");

exportBtn.addEventListener("click", () => {
  toast.classList.add("show");

  setTimeout(() => {
    toast.classList.remove("show");
  }, 3000);
});

// ===== DATE RANGE SYNC =====
const trendText = document.getElementById("trendRange");

// ===== HÀM FORMAT DATE =====
function formatDate(date) {
  return date.toLocaleDateString("en-US", {
    month: "short",
    day: "numeric",
    year: "numeric"
  });
}

// ===== NGÀY HÔM NAY =====
const today = new Date();
trendText.innerText = `${formatDate(today)} to ${formatDate(today)}`;

// ===== FLATPICKR =====
flatpickr("#dateRange", {
  mode: "range",
  dateFormat: "M d, Y",
  defaultDate: [today, today], // 🔥 set mặc định

  onChange: function (selectedDates) {
    if (selectedDates.length === 2) {
      const start = formatDate(selectedDates[0]);
      const end = formatDate(selectedDates[1]);

      trendText.innerText = `${start} to ${end}`;
    }
  }
});
