FactoryBot.define do
  factory :credit_record do
    user { nil }
    category { "MyString" }
    reason { "MyString" }
    num { 1 }
    operator { "MyString" }
    markup { "MyString" }
  end
end
