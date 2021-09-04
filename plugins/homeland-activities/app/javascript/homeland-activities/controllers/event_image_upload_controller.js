
import { Controller } from "stimulus"
export default class extends Controller {
  static targets = ["file", 'preview', 'button', 'urlInput']
  connect() {
    console.log("event image upload loaded")
  }
  click(event){
    event.preventDefault();
    this.fileTarget.click();
  }
  changed(event) {
    console.log(event)
    let file = event.target.files[0]
    if (file.size > 5 * 1024 * 1024){
      App.alert("上传失败, 大小超过5M");
      this.buttonTarget.innerText = "上传图片"
      return
    }

    const formData = new FormData();
    formData.append("file", file);
    this.buttonTarget.innerText = "上传中..."
    let that = this;
    $.ajax({
      url: '/photos',
      type: "POST",
      data: formData,
      dataType: "JSON",
      processData: false,
      contentType: false,
      beforeSend() {

      },
      success(e, status, res) {
        that.previewTarget.src = e.url
        that.urlInputTarget.value = e.url
        that.previewTarget.width= "160"
        that.previewTarget.height = "90"
        that.buttonTarget.innerText = "上传图片"
      },
      error(res) {
        App.alert("上传失败, 只支持图片");
        that.buttonTarget.innerText = "上传图片"
      }

    });
  }
}