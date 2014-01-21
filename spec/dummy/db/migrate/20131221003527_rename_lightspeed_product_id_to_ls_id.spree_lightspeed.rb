# This migration comes from spree_lightspeed (originally 20131220013633)
class RenameLightspeedProductIdToLsId < ActiveRecord::Migration
  def change
    rename_column :spree_variants, :lightspeed_product_id, :ls_id 
  end
end
