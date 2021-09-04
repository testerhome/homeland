import { Controller } from "stimulus"
export default class extends Controller {
  connect(){
    window._topicView = new TopicView({parentView: this.element});
  }
}
