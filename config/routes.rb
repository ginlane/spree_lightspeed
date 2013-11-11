#SpreeLightspeed::Engine.routes.draw do
#end

Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :products do
      collection do
        get :lightspeed_collection
      end
    end
  end
end
