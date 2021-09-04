module Homeland
  module Activities
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
