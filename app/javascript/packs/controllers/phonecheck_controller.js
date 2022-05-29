import { Controller } from "stimulus"

export default class extends Controller {
  static targets =["phoneNumber", "captcha", 'sendButton']
  connect(){
    console.log(this.phoneNumberTarget)
    this.disable_click = false;
  }

  sendMsg(e){
    e.preventDefault();
    if (this.disable_click) {
      return 
    }
    if (this._isMobile(this.phoneNumberTarget.value)) {
      this._sendPhone()

    }else {
      alert('手机号码不正确')
    }
    // alert('sndSMS')
  }

  _sendPhone(e){

    const code = this.captchaTarget.value
    const phoneNumber = this.phoneNumberTarget.value

    console.log(code, phoneNumber)
    $.ajax({
      type: "POST",
      url: "/api/v3/users/send_phone_code", 
      data: {_rucaptcha: code, phone: phoneNumber}, 
      success: (data) => {
        if (data.msg === 'ok') {
          alert('发送成功')
          this._resetCaptcha()
          this._countDown(60, 0)
        }else {
          alert(data.message)
          this._resetCaptcha()
        }
      },
      error: (data) => {
        
        this._resetCaptcha()
        
        if (data && data.responseJSON && data.responseJSON.error) {
          alert(data.responseJSON.error)
        }else {
          alert('验证码错误')
        }
      }
    });
  }

  _resetCaptcha(){
    $(".rucaptcha-image").trigger("click")
  }

  

  _isMobile (mobile) {
    return /^1[3-9]\d{9}$/.test(mobile)
  }

  _countDown(timestamp = 60, type = 0) {


    this.disable_click = true
    let seconds = timestamp // 倒计时总秒数

    // 如果目标时间小于等于当前时间，不需要继续进行了
    if (seconds <= 0) return
  
    // 定时器
    this.timer = setInterval(() => {
      seconds--
      let result = type == 0 ? seconds + '秒后可重发' : ""
      console.log(result)
      this.sendButtonTarget.innerText = result
        $(this.sendButtonTarget).attr('disabled', true)
  
      // 把转换后的结果显示出来
      this.sendButtonTarget.innerHTML = result
  
      if (seconds <= 0) {
        this.sendButtonTarget.disabled = false

        clearInterval(this.timer)
        this.sendButtonTarget.innerText = '重新发送'
        this.disable_click = false
        $(this.sendButtonTarget).attr('disabled', false)
      }
    }, 1000)
  }
  disconnect(){
    if (this.timer) {
      clearInterval(this.timer)
      this.disable_click = false
      $(this.sendButtonTarget).attr('disabled', false)
      $(this.sendButtonTarget).text('重新发送')
    }
  }
  
}