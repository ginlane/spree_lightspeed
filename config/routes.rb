#SpreeLightspeed::Engine.routes.draw do
#end

Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :products do
      collection do
        get :new_lightspeed_products
        post :lightspeed_import_all
      end

      member do
        post :lightspeed_import
        get :lightspeed_variants
      end
    end
  end
end
