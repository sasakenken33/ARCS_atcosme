document.addEventListener("DOMContentLoaded", function() {
  document.getElementById("btn").addEventListener("onclick", function () {
    let xhr = new XMLHttpRequest();
    let status = document.getElementById("status");
    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4) {

      } else {
        status.textContent = "処理中・・・";
      }
    }
  }, false);
}, false);