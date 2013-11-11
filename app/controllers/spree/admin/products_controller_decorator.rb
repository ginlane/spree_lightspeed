module Spree
  module Admin
    ProductsController.class_eval do
      def lightspeed_collection
        remote = Lightspeed::Product.all
        remote_ids = remote.map(&:id)

        local = Spree::Product.
          includes(:variants).
          where(:"spree_variants.lightspeed_product_id" => remote_ids)

        delta = []
        remote.each do |ls_product|
          next if local.select{|p| p.lightspeed_product_id == ls_product.id}.any?
          delta << ls_product
        end

        respond_to do |format|
          format.json { render :json => delta }
        end
      end
    end
  end
end
