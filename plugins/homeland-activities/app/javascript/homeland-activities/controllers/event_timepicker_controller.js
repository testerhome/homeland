require("moment/locale/zh-cn")
require("pc-bootstrap4-datetimepicker")

import { Controller } from "stimulus"
export default class extends Controller {
  connect(){
    $.extend(true, $.fn.datetimepicker.defaults, {
      icons: {
        time: 'fas fa-stopwatch',

      },
      format: 'YYYY-MM-DD HH:mm'
    });

    $(".event-date").datetimepicker({})
  }
}