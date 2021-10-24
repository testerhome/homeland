import { Controller } from "stimulus"
const SelectClassList = ["tw-text-blue-400", "tw-border-2", 'tw-border-solid', "tw-border-blue-400"]

export default class extends Controller {
  static values = {
    currentVariantId: String,
    currentUserCredit: Number
  }

  static targets = [
    "variants",
    "creditPrice",
    "variantImage",
    "buyButton"
  ]

  selectVariant(event){
    event.preventDefault();
    let ele = event.target
    if (ele.classList.contains("variant")){
      this._selectElement(ele)
    }
  }

  connect(){
    console.log(this.currentVarintIdValue)
    if (this.currentVariantIdValue != "") {
      let ele = [].slice.call(this.variantsTarget.children).find(ele => ele.dataset.id == this.currentVariantIdValue)
      this._selectElement(ele)
    }
  }

  _resetVariantSelect(){
    [].slice.call(this.variantsTarget.children).forEach(ele => {
      SelectClassList.forEach(className => {ele.classList.remove(className)})
    })

  }
  _selectElement(ele){
    this._resetVariantSelect()
    SelectClassList.forEach(className => {ele.classList.add(className)})
    // ele.classList.add("tw-text-blue-400")
    this.creditPriceTarget.innerText = ele.dataset.price
    this.currentPrice = parseInt(ele.dataset.price)
    this.variantImageTarget.src = ele.dataset.image
    if (ele.dataset.inStock === "false"){
      this.buyButtonTarget.classList.add("disabled")
      this.buyButtonTarget.innerText = '没有足够的库存'
      return
    }

    if (this.currentUserCreditValue < 0 ) {
      this.buyButtonTarget.innerText = '购买'
      this.buyButtonTarget.href = `/credit_variant_orders/new?credit_variant_id=${ele.dataset.id}&num=1`
      return
    }

    if (this.currentUserCreditValue < this.currentPrice){
      this.buyButtonTarget.classList.add("disabled")
      this.buyButtonTarget.innerText = '没有足够的积分'
    }else {
      this.buyButtonTarget.classList.remove("disabled")
      this.buyButtonTarget.innerText = '购买'
      this.buyButtonTarget.href = `/credit_variant_orders/new?credit_variant_id=${ele.dataset.id}&num=1`
    }
  }

  buy(event){
    // event.preventDefault();
    // if (this.buyButtonTarget.classList.contains("disabled")){
    //   return
    // }
    // let ele = event.target
    // let data = {
    //   variant_id: ele.dataset.id,
    //   quantity: 1
    // }
    // event.target
  }
}