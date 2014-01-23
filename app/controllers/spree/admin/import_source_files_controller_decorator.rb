module Spree
  module Admin
    ImportSourceFilesController.class_eval do
      def send_to_lightspeed
        if import_source_file.imported_to_lightspeed?
          flash[:error] = 'Batch already imported to LightSpeed'
        else
          bp = SpreeLightspeed::BatchProcessor.new import_source_file.id, import_source_file.products
          bp.send_to_lightspeed!
        end
        redirect_to :back
      end

      def synchronize_stock
        redirect_to :back
      end

      def import_source_file
        @cached_import_source_file ||= ImportSourceFile.find params[:id]
      end
    end
  end
end
