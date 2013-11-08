Spree::Zone.class_eval do
  def self.global
    find_by(name: 'GlobalZone') || FactoryGirl.create(:global_zone)
  end
end

FactoryGirl.define do
  sequence(:random_string)      { Faker::Lorem.sentence }
  sequence(:random_description) { Faker::Lorem.paragraphs(1 + Kernel.rand(5)).join("\n") }
  sequence(:random_email)       { Faker::Internet.email }
end
