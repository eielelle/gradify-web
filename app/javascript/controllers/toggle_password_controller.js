import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []

  connect() {
    // this.element.textContent = "Hello World!"
  }

  togglePasswordFields() {
    const passwordFields = document.getElementById('password-fields');
    const button = document.getElementById('edit-password-btn');
    const isHidden = passwordFields.classList.toggle('hidden');

    button.textContent = !isHidden ? 'Hide Edit Password' : 'Show Edit Password';
  }
}
