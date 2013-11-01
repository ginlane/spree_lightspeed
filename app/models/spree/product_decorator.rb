Spree::Product.class_eval do
  delegate_belongs_to :master, :lightspeed_product_id
end
