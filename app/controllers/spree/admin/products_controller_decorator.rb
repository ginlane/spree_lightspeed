module Spree
  module Admin
    ProductsController.class_eval do
      before_filter :lightspeed_collection, :only => [:new_lightspeed_products, :lightspeed_import_all]

      def lightspeed_import_all
        Spree::ProductImporter.import_delta!
        flash[:success] = "New Lightspeed Products imported."
        redirect_to request.referer || spree.admin_products_path
      end

      def lightspeed_variants
        p = Lightspeed::Product.find params[:id]
        @collection = p.variants

        respond_to do |format|
          format.json { render :json => @collection }
        end
      end

      def lightspeed_collection
        remote = Lightspeed::Product.all(filters: {master_model_eq: 1})
        remote_ids = remote.map(&:id)

        local = Spree::Variant.
          where(:lightspeed_product_id => remote_ids)

        @collection = []
        remote.each do |ls_product|
          next if local.select{|p| p.lightspeed_product_id == ls_product.id}.any?
          @collection << ls_product
        end
      end

      def new_lightspeed_products
        respond_to do |format|
          format.json { render :json => @collection }
          format.html
        end
      end
    end
  end
end
