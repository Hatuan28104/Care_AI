// load sidebar + header
fetch("../layout/sidebar.html")
  .then(res => res.text())
  .then(html => document.getElementById("sidebar").innerHTML = html);

fetch("../layout/header.html")
  .then(res => res.text())
  .then(html => document.getElementById("header").innerHTML = html);
