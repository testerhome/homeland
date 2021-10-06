import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ 'template', 'panel']

  connect() {
    console.log('loaded')
  }
  removeItem(event){
    event.preventDefault();
    event.target.parentElement.remove()
  }

  addItem(event){
    event.preventDefault()
    let clone = document.importNode(this.templateTarget.content, true);
    this.panelTarget.appendChild(clone)
  }

}