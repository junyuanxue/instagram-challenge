include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :comment do
    content { Faker::Hipster.sentence }
    photo
    user
  end
end
