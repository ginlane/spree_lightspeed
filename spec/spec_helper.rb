# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require 'rspec/rails'
#require 'capybara/rails'
#require 'capybara/rspec'

require 'factory_girl'
require 'ffaker'
require 'support/factory_setup'

# Loading up select Spree::Core factories
['shipping_category', 'tax_category', 'stock_location', 'country', 'state', 'product'].each do |model|
  require "spree/testing_support/factories/#{model}_factory"
end

require 'vcr_setup'
require 'database_cleaner'

require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/preferences'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/flash'
require 'spree/testing_support/url_helpers'
require 'spree/testing_support/order_walkthrough'

require 'paperclip/matchers'

ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

Lightspeed::Client.config_from_yaml 'config/lightspeed.yml', :test

RSpec.configure do |config|
  config.include RspecEnv

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include Spree::TestingSupport::Preferences
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::ControllerRequests
  config.include Spree::TestingSupport::Flash

end

