# This migration comes from spree_importer (originally 20131230201855)
class AddBatchIdToVariant < ActiveRecord::Migration
  def change
    add_column :spree_variants, :batch_id, :integer
    add_index :spree_variants, :batch_id
  end
end
