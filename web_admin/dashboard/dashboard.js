export const API_BASE = "https://web-admin-ck6m.onrender.com";
let chartInstance = null;
let currentTab = 0;
let selectedStart = null;
let selectedEnd = null;

/* ==========================
   COMMON
========================== */

async function fetchData(url) {
  const res = await fetch(url);
  const json = await res.json();
  return json.data || [];
}

function isInRange(date, start, end) {
  if (!start || !end) return true;
  return date >= start && date <= end;
}

function groupByDate(data, dateField, valueField = null) {
  const map = {};

  data.forEach(item => {
    console.log("ITEM:", item); // 🔥 xem từng record

    if (!item[dateField]) {
      console.warn("MISSING FIELD:", dateField, item);
      return;
    }

    const d = new Date(item[dateField]);
    if (isNaN(d)) {
      console.warn("INVALID DATE:", item[dateField]);
      return;
    }

    if (!isInRange(d, selectedStart, selectedEnd)) return;

    const key = d.toISOString().split("T")[0];

    map[key] = (map[key] || 0) + (valueField ? item[valueField] : 1);
  });

  console.log("MAP:", map);

  return map;
}

/* ==========================
   RENDER CHART
========================== */
function renderChart(labels, data, label, type = "line") {
  const ctx = document.getElementById("mainChart");
  if (!ctx) return;

  if (chartInstance) chartInstance.destroy();

  chartInstance = new Chart(ctx, {
    type,
    data: {
      labels,
      datasets: [{
        label,
        data,
        borderWidth: 2,
        tension: 0.3
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false
    }
  });
}

/* ==========================
   LOAD CHART
========================== */
async function loadChart(url, dateField, label, valueField = null) {
  const data = await fetchData(url);

  console.log("DATA:", data); // 🔥 debug

  const map = groupByDate(data, dateField, valueField);

  const sorted = Object.entries(map).sort(
    (a, b) => new Date(a[0]) - new Date(b[0])
  );

  renderChart(
    sorted.map(i => new Date(i[0]).toLocaleDateString("vi-VN")),
    sorted.map(i => i[1]),
    label
  );
}

/* ==========================
   LOAD CURRENT TAB
========================== */
function loadCurrentChart() {
  if (currentTab === 0)
    loadChart(`${API_BASE}/profile/dashboard/users`, "ngaytao", "Người dùng");

  if (currentTab === 1)
    loadChart(`${API_BASE}/api/chat/conversations`, "date", "Hội thoại", "total");

  if (currentTab === 2)
    loadChart(`${API_BASE}/notification/alerts`, "createdat", "Cảnh báo");
}

/* ==========================
   TABS
========================== */
function initTabs() {
  const tabs = document.querySelectorAll(".tabs button:not(.export)");

  tabs.forEach((tab, index) => {
    tab.addEventListener("click", () => {
      tabs.forEach(t => t.classList.remove("active"));
      tab.classList.add("active");

      currentTab = index;
      loadCurrentChart();
    });
  });
}

/* ==========================
   EXPORT
========================== */

function pushSection(rows, title, map) {
  rows.push([`=== ${title} ===`]);
  rows.push(["Date", "Total"]);

  Object.entries(map).forEach(([date, value]) => {
    rows.push([date, value]);
  });

  rows.push([]);
}

function initExport() {
  const exportBtn = document.querySelector(".tabs .export");
  const toast = document.getElementById("toast");

  if (!exportBtn || !toast) return;

  exportBtn.addEventListener("click", async () => {
    try {
      const rows = [];

      const [users, conversations, alerts] = await Promise.all([
        fetchData(`${API_BASE}/profile/dashboard/users`),
        fetchData(`${API_BASE}/api/chat/conversations`),
        fetchData(`${API_BASE}/notification/alerts`)
      ]);

      const userMap = groupByDate(users, "ngaytao");
      const interactionMap = groupByDate(conversations, "date", "total");
      const alertMap = groupByDate(alerts, "createdat");

      pushSection(rows, "USERS", userMap);
      pushSection(rows, "INTERACTIONS", interactionMap);
      pushSection(rows, "ALERTS", alertMap);

      exportCSV("dashboard_all.csv", rows);

      toast.classList.remove("hidden");
      setTimeout(() => toast.classList.add("hidden"), 3000);

    } catch (err) {
      console.error("Export error:", err);
    }
  });
}

/* ==========================
   DATE FORMAT
========================== */
function formatDate(date) {
  return date.toLocaleDateString("vi-VN", {
    month: "short",
    day: "numeric",
    year: "numeric"
  });
}

/* ==========================
   DATE PICKER
========================== */
function initDatePicker() {
  const trendText = document.getElementById("trendRange");
  const today = new Date();

  trendText.innerText = `${formatDate(today)} to ${formatDate(today)}`;

  flatpickr("#dateRange", {
    mode: "range",
    locale: "vn",
    dateFormat: "M d, Y",
    defaultDate: [today, today],

    onChange: function (selectedDates) {
      if (selectedDates.length === 2) {
        selectedStart = selectedDates[0];
        selectedEnd = selectedDates[1];
        selectedEnd.setHours(23, 59, 59, 999);

        trendText.innerText =
          `${formatDate(selectedStart)} to ${formatDate(selectedEnd)}`;

        loadCurrentChart();
        loadStats();
      }
    }
  });
}

/* ==========================
   STATS
========================== */
async function loadStats() {
  try {
    const [users, conversations, alerts] = await Promise.all([
      fetchData(`${API_BASE}/profile/dashboard/users`),
      fetchData(`${API_BASE}/api/chat/conversations`),
      fetchData(`${API_BASE}/notification/alerts`)
    ]);

    const totalUsers = users.filter(u =>
      u.ngaytao && isInRange(new Date(u.ngaytao), selectedStart, selectedEnd)
    ).length;

    const totalInteractions = conversations.reduce((sum, c) => {
      const d = new Date(c.date);
      return isInRange(d, selectedStart, selectedEnd)
        ? sum + c.total
        : sum;
    }, 0);

    const totalAlerts = alerts.filter(a =>
      a.createdat && isInRange(new Date(a.createdat), selectedStart, selectedEnd)
    ).length;

    document.getElementById("totalUsers").innerText = totalUsers;
    document.getElementById("totalInteractions").innerText = totalInteractions;
    document.getElementById("totalAlerts").innerText = totalAlerts;

  } catch (err) {
    console.error("Stats error:", err);
  }
}

/* ==========================
   EXPORT CSV
========================== */
function exportCSV(filename, rows) {
  const csvContent = rows
    .map(row => row.map(v => `"${v ?? ""}"`).join(","))
    .join("\n");

  const blob = new Blob([csvContent], {
    type: "text/csv;charset=utf-8;"
  });

  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = filename;
  link.click();
}

/* ==========================
   INIT
========================== */
document.addEventListener("DOMContentLoaded", () => {
  initTabs();
  initExport();
  initDatePicker();

  loadCurrentChart();
  loadStats();
});
