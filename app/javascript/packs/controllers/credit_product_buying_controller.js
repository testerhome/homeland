import { Controller } from "stimulus"

export default class extends Controller {
  static values = {
    variants: Array,
    current_varint: Number
  }
  static targets = [
    "main_image",
    "price",
    "current_variant_input"
  ]

  connect(){
    console.log(this.variantsValue)
  }
}