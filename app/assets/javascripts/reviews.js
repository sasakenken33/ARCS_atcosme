// 読み込みが完了したら
document.addEventListener('turbolinks:load', function () {
  document.querySelector("#btn").addEventListener("click", function() {
    let status = document.querySelector(".loader.hidden")
    status.classList.remove("hidden");
  });
});