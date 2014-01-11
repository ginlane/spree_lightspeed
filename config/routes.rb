Spree::Core::Engine.add_routes do
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

    resources :import_source_files do
      member do
        post :send_to_lightspeed
        post :synchronize_stock
      end
    end
  end
end
