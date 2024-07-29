// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
// import "flowbite";
// import "flowbite-datepicker";
//import "/node_modules/flowbite/dist/datepicker.turbo.js";

Turbo.setConfirmMethod((message, element) => {
  console.log(element.dataset)
  console.log(element)
  let dialog = document.getElementById("turbo-confirm");
  let btn = dialog.querySelector(".btn-confirm");
  btn.classList.add(element.dataset.btnClass);
  dialog.querySelector(".text").textContent = message;
  dialog.showModal();

  return new Promise((resolve, reject) => {
    dialog.addEventListener(
      "close",
      () => {
        resolve(dialog.returnValue == "confirm");
      },
      { once: true }
    );
  });
});
