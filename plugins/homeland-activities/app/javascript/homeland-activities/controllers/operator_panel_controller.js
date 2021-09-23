
import { Controller } from "stimulus"
export default class extends Controller {
  static targets = [ "addButton", 'delButton', 'panel', 'template' ]
  static values = {
    'show': Boolean,
    'data': Array
  }
  connect() {
    this.dataValue.forEach(element => {
      let clone = document.importNode(this.templateTarget.content, true);
      clone.querySelector('input[name="event[cooperators][][name]"]').value = element.name;
      clone.querySelector('input[name="event[cooperators][][url]"]').value = element.url;
      this.panelTarget.appendChild(clone);
    })
  }
  addButtonClick(e){
    e.preventDefault();
    if (this.element.querySelectorAll('.cooperator_name').length >= 10){
      return alert("最多支持10个协办者")
    }
    let clone = document.importNode(this.templateTarget.content, true);
    this.panelTarget.appendChild(clone);
  }
  findAncestor (el, sel) {
    while ((el = el.parentElement) && !((el.matches || el.matchesSelector).call(el,sel)));
    return el;
  }
  remove(e){
    e.preventDefault();
    this.findAncestor(e.target, '.cooperator_panel').remove();

  }
}