class RenameLightspeedProductIdToLsId < ActiveRecord::Migration
  def change
    rename_column :spree_variants, :lightspeed_product_id, :ls_id 
  end
end
