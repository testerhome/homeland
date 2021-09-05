import { Controller } from "stimulus"
import Turbolinks from "turbolinks"

export default class extends Controller {
  static values = {
    day: String,
    count: Number,
    status: Boolean
  }
  connect(){
    console.log(this.dayValue)
  }
  click(e){
    e.preventDefault()
    if (this.countValue == 0 ){
      return
    }
    let url = new URL(window.location.href)
    let params = new URLSearchParams(url.search);
    if (this.statusValue == false){
      params.delete('filter_date')
      params.append('filter_date', this.dayValue)
    }else{
      params.delete('filter_date')
    }
    Turbolinks.visit(url.origin + url.pathname + '?' + params.toString())

  }
}