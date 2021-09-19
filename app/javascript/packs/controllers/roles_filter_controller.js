import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["main", 'sub']
  static values = {
    statesInfo: Array,
    stateBlank: Boolean,
    selectedState: String
  }
  connect() {
    // console.log(this.subTemplateTarget.content)
    console.log(this.statesInfoValue)
    this._rebindSub(this.mainTarget.value,this.selectedStateValue)
  }

  select(event) {
    event.preventDefault();
    const key = event.target.value
    this._rebindSub(key)

  }

  _rebindSub(key, selectedValue = null){
    const substates =  this._subStateInfo(key)
    let init = this.stateBlankValue == true ? "<option value>全部类别</option>" : ""
    this.subTarget.innerHTML =  init + substates.map(x => `<option value="${x[1]}">${x[2]}</option>`).join("")

    if (selectedValue != null){
      this.subTarget.value = selectedValue
    }

  }

  _subStateInfo(key) {
    if (key== "" || key == null) {
      return this.statesInfoValue
    }
    let [min, max] = key.split("--").map(x => parseInt(x))
    return this.statesInfoValue.filter((item) => {
      return item[1] >= min && item[1] <= max
    })
  }
}