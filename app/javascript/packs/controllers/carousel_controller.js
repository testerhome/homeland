import { Controller } from "stimulus"
// import Swiper from 'swiper/bundle';
// import 'swiper/css/bundle';

export default class extends  Controller {
  static swiper = null;
  connect() {
    super.connect()

    // The swiper instance.
    // this.swiper = new Swiper(this.element, {})

    // Default options for every carousels.
    // this.defaultOptions
  }

  // You can set default options in this getter.
  get defaultOptions () {
    return {
      // Your default options here
    }
  }
}