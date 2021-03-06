require 'digest/sha1'
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
      @product = @products[1]
      @variants = @products.map{|p| p.variants }.flatten.select{|v| v.batch_id == 999}
      @variant = @product.variants[0]
      @variant.sku = Digest::SHA1.hexdigest(Time.now.to_s)
      @variant.save
    end

    describe 'on ::new' do
      it 'accepts a batch id and a collection of products' do
        bp.batch_id.should == 999
      end
    end

    describe 'on #send_to_lightspeed' do
      it 'exports and maps records' do
        ls_product_by_sku(@variant.sku).should be_empty
        bp.send_to_lightspeed!
        ls_product_by_sku(@variant.sku).size.should == 1

        @variants.each do |record|
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
