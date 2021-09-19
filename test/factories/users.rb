# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "name#{n}" }
    sequence(:login) { |n| "login#{n}" }
    sequence(:email) { |n| "email#{n}@gethomeland.com" }
    password { "password" }
    password_confirmation { "password" }
    location { "China" }
    created_at { 100.days.ago }
    certified_at { 1.hours.ago }
  end

  factory :avatar_user, parent: :user do
    avatar { File.open(Rails.root.join("test/fixtures/test.png")) }
  end

  factory :admin, parent: :user do
    state { "admin" }
  end

  factory :vip, parent: :user do
    state { "vip" }
  end

  factory :hr, parent: :user do
    state { "hr" }
  end

  factory :public_simple, parent: :user do
    state { "public_simple" }
  end
  factory :public_flow, parent: :user do
    state { "public_flow" }
  end
  factory :public_cooperation, parent: :user do
    state { "public_cooperation" }
  end
  factory :enterprise_non_subscriber, parent: :user do
    state { "enterprise_non_subscriber" }
  end
  factory :enterprise_subscriber, parent: :user do
    state { "enterprise_subscriber" }
  end

  factory :newbie, parent: :user do
    created_at { 1.hours.ago }
  end

  factory :uncertified_user, parent: :user do
    certified_at { nil }
  end

  factory :blocked_user, parent: :user do
    created_at { 30.days.ago }
    state { "blocked" }
  end

  factory :deleted_user, parent: :user do
    created_at { 100.days.ago }
    state { "deleted" }
  end


end
