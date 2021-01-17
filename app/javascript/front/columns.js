window.ColumnView = Backbone.View.extend({
  el: "body",
  events: {
    "click a.button-follow-column": "followColumn",
    "click a.button-block-column": "blockColumn"
  },
  initialize: function(opts) {
    return this.parentView = opts.parentView;
  },
  followColumn: function(e) {
    var btn, column_id, followerCounter, span;
    btn = $(e.currentTarget);
    column_id = btn.data("id");
    span = btn.find("span");
    followerCounter = $(".follow-info .followers[data-login='" + column_id + "'] .counter");
    if (btn.hasClass("active")) {
      $.ajax({
        url: "/columns/" + column_id + "/unfollow",
        type: "DELETE",
        success: function(res) {
          if (res.code === 0) {
            btn.removeClass('active');
            span.text("关注");
            return followerCounter.text(res.data.followers_count);
          }
        }
      });
    } else {
      $.ajax({
        url: "/columns/" + column_id + "/follow",
        type: 'POST',
        success: function(res) {
          if (res.code === 0) {
            btn.addClass('active').attr("title", "");
            span.text("取消");
            return followerCounter.text(res.data.followers_count);
          }
        }
      });
    }
    return false;
  },
  blockColumn: function(e) {
    var btn, column_id, span;
    btn = $(e.currentTarget);
    column_id = btn.data("id");
    span = btn.find("span");
    if (btn.hasClass("active")) {
      $.post("/columns/" + column_id + "/unblock");
      btn.removeClass('active').attr("title", "屏蔽后，社区首页列表将不会显示此用户发布的内容。");
      span.text("屏蔽");
    } else {
      $.post("/columns/" + column_id + "/block");
      btn.addClass('active').attr("title", "");
      span.text("取消");
    }
    return false;
  }
});