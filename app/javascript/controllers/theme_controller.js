import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["switch"]

  connect() {
    this.update()
  }

  changeTheme() {
    if (localStorage.getItem("theme") === "light") {
        localStorage.setItem("theme", "dark");
    } else {
        localStorage.setItem("theme", "light");
    }

    this.update()
  }

  update() {
    if (localStorage.getItem("theme") === null) {
        document.documentElement.setAttribute("data-theme", "light");
    } else {
        let themeData = localStorage.getItem("theme");
        document.documentElement.setAttribute("data-theme", themeData);

        this.updateToggler(themeData == "light");
    }
  }

  updateToggler(isLight) {
    this.switchTarget.querySelector(".theme-controller").checked = isLight
  }
}
