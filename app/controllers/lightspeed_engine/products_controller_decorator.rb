module LightspeedEngine
  ProductsController.class_eval do
    before_filter :load_spree_products, :only => :index
    helper_method :pluck_spree_product

    def pluck_spree_product ls_id
      @spree_products.select{|p| p.lightspeed_product_id == ls_id}[0]
    end

  private

    def load_spree_products
      ls_ids = @collection.map(&:id)

      @spree_products = 
        Spree::Product.
        joins(:variants).
        where(:"spree_variants.lightspeed_product_id" => ls_ids)
    end 
  
  end
end
