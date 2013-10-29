Spree::Variant.class_eval do
  
  scope :unmapped, where(:lightspeed_product_id => nil)

end
