Rails.application.routes.draw do
  mount Homeland::Activities::Engine => "/homeland-activities"
end
