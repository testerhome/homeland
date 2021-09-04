require "application_system_test_case"

module Homeland::Activities
  class EventsTest < ApplicationSystemTestCase
    setup do
      @event = homeland_activities_events(:one)
    end

    test "visiting the index" do
      visit events_url
      assert_selector "h1", text: "Events"
    end

    test "creating a Event" do
      visit events_url
      click_on "New Event"

      fill_in "Category", with: @event.category
      fill_in "City", with: @event.city
      fill_in "Description", with: @event.description
      fill_in "Email", with: @event.email
      fill_in "End at", with: @event.end_at
      fill_in "Operator info", with: @event.operator_info
      fill_in "Phone", with: @event.phone
      fill_in "Realname", with: @event.realname
      fill_in "Registration end at", with: @event.registration_end_at
      fill_in "Registration open at", with: @event.registration_open_at
      fill_in "Start at", with: @event.start_at
      fill_in "Status", with: @event.status
      fill_in "Title", with: @event.title
      fill_in "Wechat or qq", with: @event.wechat_or_qq
      click_on "Create Event"

      assert_text "Event was successfully created"
      click_on "Back"
    end

    test "updating a Event" do
      visit events_url
      click_on "Edit", match: :first

      fill_in "Category", with: @event.category
      fill_in "City", with: @event.city
      fill_in "Description", with: @event.description
      fill_in "Email", with: @event.email
      fill_in "End at", with: @event.end_at
      fill_in "Operator info", with: @event.operator_info
      fill_in "Phone", with: @event.phone
      fill_in "Realname", with: @event.realname
      fill_in "Registration end at", with: @event.registration_end_at
      fill_in "Registration open at", with: @event.registration_open_at
      fill_in "Start at", with: @event.start_at
      fill_in "Status", with: @event.status
      fill_in "Title", with: @event.title
      fill_in "Wechat or qq", with: @event.wechat_or_qq
      click_on "Update Event"

      assert_text "Event was successfully updated"
      click_on "Back"
    end

    test "destroying a Event" do
      visit events_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Event was successfully destroyed"
    end
  end
end
