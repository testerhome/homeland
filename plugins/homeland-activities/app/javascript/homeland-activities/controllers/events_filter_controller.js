
import { Controller } from "stimulus"
export default class extends Controller {
  static values = {
    nameId: String
  }
  connect() {
    console.log("events filter controller works name id = ", this.nameIdValue)
  }
  click(event){
    event.preventDefault();
    console.log(event.target.text)
    $(`#${this.nameIdValue}`).val(event.target.text)
    $("#filter").submit();
  }
}