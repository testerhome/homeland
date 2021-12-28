import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "source", "target" ];
  static values = {
    url: String,
    filterName: String,
    displayAttribute: String
  }

  handleSelectChange() {
    this.populateSelect(this.sourceTarget.value);
  }

  connect() {
    // alert(123);
  }

  populateSelect(sourceId, targetId = null) {
    fetch(`${this.urlValue}?${this.filterNameValue}=${sourceId}`, {
      credentials: 'same-origin'
    })
      .then(response => response.json())
      .then(data => {
        const selectBox = this.targetTarget;
        selectBox.innerHTML = '';
        selectBox.appendChild(document.createElement('option'));

        data.forEach(item => {
          const opt = document.createElement('option');
          opt.value = item.id;
          opt.innerHTML = item[this.displayAttributeValue];
          opt.selected = parseInt(targetId) === item.id;
          selectBox.appendChild(opt);
        });
      });
  }
}