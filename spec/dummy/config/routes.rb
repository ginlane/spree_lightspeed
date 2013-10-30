Rails.application.routes.draw do

  mount SpreeLightspeed::Engine => "/spree_lightspeed"
  mount Spree::Core::Engine => "/"
end
