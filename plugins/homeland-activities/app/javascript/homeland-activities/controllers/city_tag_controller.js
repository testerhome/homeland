
import { Controller } from "stimulus"
import Select2 from "select2";

export default class extends Controller {
  static targets = ["cityInput"]

  connect() {
    $(this.cityInputTarget).select2({
      tags: true
    });
    // let tagify = new Tagify(this.cityInputTarget, {
    //   enforceWhitelist: true,
    //   mode : "select",
    //   whitelist: ["线上举办", "北京", "上海", "广州", "深圳", "成都", "杭州", "重庆", "武汉", "天津", "南京", "西安", "长沙" ]
    // })
    // // tagify.on('add', this.onAddTag)
    // // tagify.DOM.input.addEventListener('focus', this.onSelectFocus)
  }



}