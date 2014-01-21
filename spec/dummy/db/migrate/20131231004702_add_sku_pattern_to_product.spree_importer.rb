# This migration comes from spree_importer (originally 20131114181542)
class AddSkuPatternToProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :sku_pattern, :string
  end
end
