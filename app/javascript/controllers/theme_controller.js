import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["switch"]

  connect() {
    this.update()
  }

  changeTheme() {
    if (localStorage.getItem("theme") === "emerald") {
        localStorage.setItem("theme", "luxury");
    } else {
        localStorage.setItem("theme", "emerald");
    }

    this.update()
  }

  update() {
    if (localStorage.getItem("theme") === null) {
        document.documentElement.setAttribute("data-theme", "emerald");
    } else {
        let themeData = localStorage.getItem("theme");
        document.documentElement.setAttribute("data-theme", themeData);

        this.updateToggler(themeData == "emerald");
    }
  }

  updateToggler(isLight) {
    this.switchTarget.querySelector(".theme-controller").checked = isLight
  }
}
