require "test_helper"

module Homeland::Activities
  class EventsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @event = homeland_activities_events(:one)
    end

    test "should get index" do
      get events_url
      assert_response :success
    end

    test "should get new" do
      get new_event_url
      assert_response :success
    end

    test "should create event" do
      assert_difference('Event.count') do
        post events_url, params: { event: { category: @event.category, city: @event.city, description: @event.description, email: @event.email, end_at: @event.end_at, operator_info: @event.operator_info, phone: @event.phone, realname: @event.realname, registration_end_at: @event.registration_end_at, registration_open_at: @event.registration_open_at, start_at: @event.start_at, status: @event.status, title: @event.title, wechat_or_qq: @event.wechat_or_qq } }
      end

      assert_redirected_to event_url(Event.last)
    end

    test "should show event" do
      get event_url(@event)
      assert_response :success
    end

    test "should get edit" do
      get edit_event_url(@event)
      assert_response :success
    end

    test "should update event" do
      patch event_url(@event), params: { event: { category: @event.category, city: @event.city, description: @event.description, email: @event.email, end_at: @event.end_at, operator_info: @event.operator_info, phone: @event.phone, realname: @event.realname, registration_end_at: @event.registration_end_at, registration_open_at: @event.registration_open_at, start_at: @event.start_at, status: @event.status, title: @event.title, wechat_or_qq: @event.wechat_or_qq } }
      assert_redirected_to event_url(@event)
    end

    test "should destroy event" do
      assert_difference('Event.count', -1) do
        delete event_url(@event)
      end

      assert_redirected_to events_url
    end
  end
end
