spree_lightspeed
================

## Install

Edit the end-app's Gemfile and ass these entries:
```ruby
  gem 'lightspeed_engine', :github => 'ginlane/lightspeed_engine'
  gem 'spree_lightspeed', :github => 'ginlane/spree_lightspeed'
```

Bundle with ```bundle``` in the project dir. 

Then proceed to mount the engines in ```config/routes.rb```:
```ruby
  mount LightspeedEngine::Engine, :at => '/admin/'
```

Extension migrations do not need to be manually added. They will be injected into the host app's migration path at loadtime.
