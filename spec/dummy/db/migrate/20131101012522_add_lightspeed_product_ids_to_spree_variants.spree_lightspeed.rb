# This migration comes from spree_lightspeed (originally 20131028190117)
class AddLightspeedProductIdsToSpreeVariants < ActiveRecord::Migration
  def change
    add_column :spree_variants, :lightspeed_product_id, :integer
    add_index :spree_variants, :lightspeed_product_id
  end
end
