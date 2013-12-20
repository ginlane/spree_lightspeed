Spree::Product.class_eval do
  delegate_belongs_to :master, :ls_id
end
