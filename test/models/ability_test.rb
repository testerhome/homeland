# frozen_string_literal: true

require "test_helper"

class AbilityTest < ActiveSupport::TestCase
  test "Admin manage all" do
    admin = create :admin
    ability = Ability.new(admin)

    assert ability.can?(:manage, Topic)
    assert ability.can?(:manage, Reply)
    assert ability.can?(:manage, Section)
    assert ability.can?(:manage, Node)
    assert ability.can?(:manage, Photo)
    assert ability.can?(:manage, Comment)
    assert ability.can?(:manage, Team)
    assert ability.can?(:manage, TeamUser)
  end

  test "Maintainer manage Topic, Node, Reply" do
    node1 = create(:node, name: "node1")
    node2 = create(:node, name: "node2")
    user = create :user, state: :maintainer
    topic1 = create(:topic, node: node1)
    topic2 = create(:topic, node: node2)
    reply_to_topic1_list = create_list(:reply, 10, topic: topic1)
    reply_to_topic2_list = create_list(:reply, 10, topic: topic2)

    user.update(node_assignment_ids: [node1.id])

    ability = Ability.new(user)
    assert ability.can?(:manage, topic1)
    assert_not ability.can?(:manage, topic2)
    assert ability.can?(:create, Team)
    reply_to_topic1_list.each { |reply| assert ability.can?(:manage, reply) }
    reply_to_topic2_list.each { |reply| assert_not ability.can?(:manage, reply) }
  end

  test "Vip manage wiki" do
    vip = create :vip
    ability = Ability.new(vip)

    assert ability.cannot?(:suggest, Topic)
    assert ability.cannot?(:unsuggest, Topic)
    assert ability.can?(:create, Team)
  end

  test "Vip create topic" do
    vip = create :vip
    ability = Ability.new(vip)

    assert ability.can?(:create, Topic)
    assert ability.can?(:create, Reply)
  end

  test "HR create topic" do
    hr = create :hr
    topic = create :topic, user: hr
    reply = create :reply, user: hr

    ability = Ability.new(hr)

    assert ability.can?(:create, Topic)
    assert ability.can?(:update, topic)
    assert ability.can?(:close, topic)
    assert ability.can?(:open, topic)
    assert ability.can?(:destroy, topic)
    assert ability.can?(:create, Reply)
    assert ability.can?(:update, reply)
    assert ability.can?(:destroy, reply)
  end

  test "Member certified? => false can not create Topic" do
    user = create :uncertified_user
    ability = Ability.new(user)
    assert_not ability.can?(:create, Topic)
  end

  test "Member" do
    user = create :avatar_user
    topic = create :topic, user: user
    topic1 = create :topic
    locked_topic = create :topic, user: user, lock_node: true
    reply = create :reply, user: user
    comment = create :comment, user: user, commentable: CommentablePage.create(name: "Fake Wiki", id: 1)
    team_owner = create :team_owner, user: user
    team_member = create :team_member, user: user

    ability = Ability.new(user)

    # Topic
    assert ability.can?(:read, Topic)
    assert ability.can?(:create, Topic)
    assert ability.can?(:update, topic)
    assert ability.can?(:destroy, topic)
    assert ability.cannot?(:suggest, Topic)
    assert ability.cannot?(:unsuggest, Topic)
    assert ability.cannot?(:ban, Topic)
    assert ability.cannot?(:open, topic1)
    assert ability.cannot?(:close, topic1)
    assert ability.cannot?(:ban, topic)
    assert ability.can?(:open, topic)
    assert ability.can?(:close, topic)
    assert ability.can?(:change_node, topic)
    assert ability.cannot?(:change_node, locked_topic)
    assert ability.can?(:change_node, topic)

    # Reply
    assert ability.can?(:read, Reply)
    assert ability.can?(:create, Reply)
    assert ability.can?(:update, reply)
    assert ability.can?(:destroy, reply)

    # Reply that Topic closed
    t = create(:topic, closed_at: Time.now)
    r = Reply.new(topic: t)

    assert ability.cannot?(:create, r)
    assert ability.cannot?(:update, r)
    assert ability.cannot?(:destroy, r)

    # Section
    assert ability.can?(:read, Section)

    # Photo
    assert ability.can?(:create, Photo)
    assert ability.can?(:read, Photo)

    # Comment
    assert ability.can?(:create, Comment)
    assert ability.can?(:read, Comment)
    assert ability.can?(:update, comment)
    assert ability.can?(:destroy, comment)

    # Team
    assert ability.cannot?(:create, Team)
    assert ability.can?(:read, Team)
    assert ability.can?(:update, team_owner.team)
    assert ability.cannot?(:update, team_member.team)
    assert ability.can?(:destroy, team_owner.team)
    assert ability.cannot?(:destroy, team_member.team)

    # TeamUser
    assert ability.can?(:accept, team_member)
    assert ability.can?(:reject, team_member)
  end

  test "Normal user but no avatar" do
    user = create :user
    ability = Ability.new(user)

    assert ability.can?(:create, Topic)
  end

  test "Newbie users" do
    Setting.stubs(:newbie_limit_time).returns("100000")
    newbie = create :newbie
    ability = Ability.new(newbie)

    assert ability.cannot?(:create, Topic)
    assert ability.can?(:create, Reply)
  end

  test "Blocked users" do
    blocked_user = create :blocked_user
    ability = Ability.new(blocked_user)

    assert ability.cannot?(:create, Topic)
    assert ability.cannot?(:create, Reply)
    assert ability.cannot?(:create, Comment)
    assert ability.cannot?(:create, Photo)
  end

  test "Deleted users" do
    deleted_user = create :deleted_user
    ability = Ability.new(deleted_user)

    assert ability.cannot?(:create, Topic)
    assert ability.cannot?(:create, Reply)
    assert ability.cannot?(:create, Comment)
    assert ability.cannot?(:create, Photo)
  end
end
