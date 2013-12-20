require 'lightspeed'
require 'spree/core'
require 'spree/api'
require 'spree/backend'
require "spree/product_importer"

module SpreeLightspeed
  class Engine < ::Rails::Engine
    isolate_namespace SpreeLightspeed

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.assets false
      g.helper false
    end
  
    config.to_prepare do
      Dir.glob("#{File.dirname(__FILE__)}/../../app/**/*_decorator*.rb").each do |c|
        require_dependency(c)
      end
    end
  end
end
