
require "test_helper"

class CreditTest < ActiveSupport::TestCase
  setup do
    Setting.stubs(:registered_credit).returns(100)


    @user = create(:user)
    @user2 = create(:user)
  end
  test "credit adds when user created" do
    assert_equal @user.reload.credit_sum, 100
    assert_equal @user.credit_records.first.num, 100
  end

  test 'user credit adds when new user audited' do

    Setting.enable_audit_users_create = true 
    user = create(:user)
    assert_equal user.reload.credit_sum, 0
    user.audit_status = 'approved'
    user.save
    assert_equal user.reload.credit_sum, 100

  end

  test 'credits added when audited' do
    node = create(:node)
    Setting.stubs(:tech_node_ids).returns([])
    Setting.stubs(:tech_topic_created_credit).returns(20)
    Setting.enable_audit_topics_create = true
    Setting.enable_audit_users_create = true 
    Setting.enable_audit_replies_create = true
    user = create(:user)
    @topic = create(:topic, user: user, node: node)
    assert_equal user.reload.credit_sum, 0
  end

  test 'credits will not add twice when reaudited' do
    Setting.enable_audit_topics_create = true
    Setting.enable_audit_users_create = true 
    Setting.enable_audit_replies_create = true
    user = create(:user)
    assert_equal user.reload.credit_sum, 0
    user.audit_status = 'approved'
    user.save
    assert_equal user.reload.credit_sum, 100
    user.audit_status = 'rejected' 
    user.save
    assert_equal user.reload.credit_sum, 100
    user.audit_status = 'approved'
    user.save
    assert_equal user.reload.credit_sum, 100
  end

  test 'receive post rewards when node is tech node' do
    node = create(:node)
    Setting.stubs(:tech_topic_created_credit).returns(20)
    Setting.stubs(:tech_node_ids).returns([node.id])


    @topic = create(:topic, user: @user, node: node)
    assert_equal @user.reload.credit_sum, 120
    assert_equal @user.credit_records.last.num, 20
  end

  test 'do nothing when node isn\'t tech node' do
    node = create(:node)
    Setting.stubs(:tech_node_ids).returns([])
    Setting.stubs(:tech_topic_created_credit).returns(20)

    @topic = create(:topic, user: @user, node: node)
    assert_equal @user.reload.credit_sum, 100
  end

  test 'minus the credits when post deleted' do
    node = create(:node)
    Setting.stubs(:tech_topic_created_credit).returns(20)
    Setting.stubs(:tech_node_ids).returns([node.id])
    @topic = create(:topic, user: @user, node: node)
    assert_equal @user.reload.credit_sum, 120
    @topic.destroy
    assert_equal @user.reload.credit_sum, 100
  end

  test 'add credits when reply the topic' do
    node = create(:node)
    Setting.stubs(:topic_user_reply_reward_credit).returns(5)
    Setting.stubs(:topic_reply_credit).returns(2)
    @topic = create(:topic, user: @user, node: node)
    assert_equal @user.reload.credit_sum, 100

    @reply = create(:reply, topic: @topic, user: @user2)
    assert_equal @user.reload.credit_sum, 105
    assert_equal @user2.reload.credit_sum, 102
  end

  test 'when the topic destroyed, remove all credits associated with the topic' do
    node = create(:node)
    Setting.stubs(:tech_topic_created_credit).returns(20)
    Setting.stubs(:tech_node_ids).returns([node.id])
    Setting.stubs(:topic_user_reply_reward_credit).returns(5)
    Setting.stubs(:topic_reply_credit).returns(2)
    @topic = create(:topic, user: @user, node: node)
    assert_equal @user.reload.credit_sum, 120

    @reply = create(:reply, topic: @topic, user: @user2)
    assert_equal @user.reload.credit_sum, 125
    assert_equal @user2.reload.credit_sum, 102

    @topic.destroy
    assert_equal @user.reload.credit_sum, 100
    assert_equal @user2.reload.credit_sum, 100
  end

  test 'add credits when topic be setting excellent by admin' do
    @topic = create(:topic, user: @user)

    assert_equal @user.reload.credit_sum, 100

    @topic.excellent!
    CreditListener.new.excellent_topic(@topic,operator: @user) # 注意， 此处因为是后台， 所以是绑定的controller
    assert_equal @user.reload.credit_sum, 600
    CreditListener.new.normal_topic(@topic,operator: @user) # 注意， 此处因为是后台， 所以是绑定的controller
    assert_equal @user.reload.credit_sum, 100
  end

  test 'minus all credits when topic banned' do
    node = create(:node)
    Setting.stubs(:tech_topic_created_credit).returns(20)
    Setting.stubs(:tech_node_ids).returns([node.id])
    Setting.stubs(:topic_user_reply_reward_credit).returns(5)
    Setting.stubs(:topic_reply_credit).returns(2)
    @topic = create(:topic, user: @user, node: node)
    assert_equal @user.reload.credit_sum, 120

    @reply = create(:reply, topic: @topic, user: @user2)
    assert_equal @user.reload.credit_sum, 125
    assert_equal @user2.reload.credit_sum, 102
    @topic.ban! reason: 'test'
    CreditListener.new().ban_topic(@topic,operator: @user, reason: "test") # 注意， 此处因为是后台， 所以是绑定的controller

    assert_equal @user.reload.credit_sum, 100
    assert_equal @user2.reload.credit_sum, 100
  end
end