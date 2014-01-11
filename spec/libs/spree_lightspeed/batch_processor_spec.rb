require 'spec_helper' 

module SpreeLightspeed
  describe BatchProcessor do
    let(:singleton){ BatchProcessor }
    let(:bp){ singleton.new(@import_source_file.id, @products) }

    before do
      @import_source_file = get_import_source_file "gin-lane-variant-export"
      @import_source_file.import!
      # batch_id == 999
      @products = @import_source_file.products[0..1]
      @product = @products[0]
      @variants = @products.map{|p| p.variants }.flatten.select{|v| v.batch_id == 999}
      @variant = @product.variants[0]
    end

    describe 'on ::new' do
      it 'accepts a batch id and a collection of products' do
        bp.batch_id.should == 999
      end
    end

    describe 'on #send_to_coresense' do
      it 'exports and maps records' do
        ls_product_by_sku(@product.sku).should be_empty
        bp.send_to_coresense!
        ls_product_by_sku(@product.sku).size.should == 1
        (@products + @variants).each do |record|
          record.reload
          record.ls_id.should be_present
        end
      end
    end

    describe 'on #prepare_new_records' do
      it 'prepares new Lightspeed records' do
        bp.prepare_new_records
        bp.ls_variants.map(&:code).should == @variants.map(&:sku)
      end
    end
  end
end
