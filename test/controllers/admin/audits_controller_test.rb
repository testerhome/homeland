require "test_helper"

class Admin::AuditsControllerTest < < Admin::ApplicationController
  test "should get index" do
    get admin_audits_index_url
    assert_response :success
  end
end
