import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast"
export default class extends Controller {
  static targets = ["toast"]

  connect() {
    console.log("Connecting to data-controller")
  }

  close() {
    this.toastTarget.style.display = "none"
  }
} 
