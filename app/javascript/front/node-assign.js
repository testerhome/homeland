window.NodeAssignView = Backbone.View.extend({
  el: "body",
  events: {
    // Refactor later
    "click #assign_modal .name a": "adminAssignNode",
    "click #assign_modal .btn-primary": "adminSubmitSelectedNode"
  },
  initialize: function(opts) {
    this.parentView = opts.parentView;
    return $('tr.not_testehome_user').attr('style', 'display: none');
  },
  adminAssignNode(e) {
    e.preventDefault()
    $(e.target).toggleClass('active')
  },

  adminSubmitSelectedNode(e) {
    e.preventDefault()
    const userId = $(e.target).data('id')
    const $selected = $('#assign_modal').find('.name a.active')

    if ($selected.size()) {
      $.ajax({
        url: `/admin/users/${userId}/assign_nodes`,
        type: "PUT",
        data: {
          node_ids: $selected.map((_, item) => $(item).data('id')).toArray()
        },
        success(res) {
          location.reload();
        },
        error(res) {
          alert(res.responseJSON.msg)
        }
      })
    } else {
      alert('请选择节点')
    }
  },
});
