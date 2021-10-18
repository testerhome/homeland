import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["panel","template"]

  connect(){
  }

  copy(e){
    e.preventDefault()
    let clone = this.templateTarget.cloneNode(true)
    this.panelTarget.appendChild(clone)
  }
}