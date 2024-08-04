import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]

  connect() {
    // this.element.textContent = "Hello World!"
    this.checked()
  }

  checked() {
    let checkboxes = document.querySelectorAll(".cb-export")

    checkboxes.forEach(checkbox => {
      checkbox.checked = this.checkboxTarget.checked
    })
  }
}
