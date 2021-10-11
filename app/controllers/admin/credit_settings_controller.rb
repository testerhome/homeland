# frozen_string_literal: true

module Admin
  class CreditSettingsController < Admin::ApplicationController
    def index
      @sections = Section.all
    end
  end
end