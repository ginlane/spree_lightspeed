module SpreeLightspeed
  class Engine < ::Rails::Engine
    isolate_namespace SpreeLightspeed

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.assets false
      g.helper false
    end

    config.to_prepare do
    end
  end
end
