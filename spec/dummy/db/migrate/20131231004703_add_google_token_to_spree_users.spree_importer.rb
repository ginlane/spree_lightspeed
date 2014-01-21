# This migration comes from spree_importer (originally 20131115163212)
class AddGoogleTokenToSpreeUsers < ActiveRecord::Migration
  def change
    add_column :spree_users, :google_token, :string
  end
end
