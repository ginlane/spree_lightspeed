require 'spec_helper'

module Spree
  describe ProductImporter do
    let(:ls_ps){ ls_products }
    let(:ls_p){ ls_product(32) }
    let(:ls_v){ ls_product(35) }
    let(:instance){ ProductImporter.new(ls_p) }

    before do
      Spree::ShippingCategory.find_or_create_by(name: 'Default')
      Spree::StockLocation.find_or_create_by(name: 'Default')

      ls_v.
        stub(:inventory).
        and_return({:available => 3})

      ls_p.
        stub(:loaded_variants).
        and_return( [ls_v] ) 

      ls_p.
        stub(:category_name).
        and_return('Apparel')
    end

    context 'when importing new records' do
      before do
        Lightspeed::Product.
          stub(:master_records).
          and_return([ls_p])
      end

      it 'creates a matching amount of records' do
        Spree::Product.count.should == 0
        ProductImporter.import_delta!
        Spree::Product.count.should == 1
        Spree::Variant.count.should == 2
      end
    end

    context 'on ::new_records' do
      context 'on first run' do
        it 'returns LS master records without Spree counterparts' do
          rs = ProductImporter.new_records(ls_ps)
          rs.size.should == ls_ps.size
        end
      end

      context 'with pre-mapped records' do
        before do
          (10..12).each do |i|
            FactoryGirl.create(:product, {lightspeed_product_id: i})
          end
        end

        it 'returns only unmapped records' do
          rs = ProductImporter.new_records(ls_ps)
          rs.size.should == ls_ps.size - 3
        end
      end
    end

    context 'when modeling an existing LS record' do
      let(:p){ instance.spree_product }

      before do
        instance.perform
      end

      it 'should copy basic attributes' do
        p.sku.should == ls_p.sku
        p.cost_price.should == ls_p.cost
        p.lightspeed_product_id.should == ls_p.id
        p.name.should == ls_p.description_copy
        p.width.should == ls_p.width
        p.available_on.should_not be_nil
      end

      it 'should set up taxonomy relations' do
        t = p.taxons.first
        t.should be_present
        t.name.should == ls_p.category_name
        t.taxonomy.name.should match(/Lightspeed Class/i)
      end

      it 'should set up option values' do
        options = p.option_types.map(&:name).join
        options.should match(/color/)
      end

      it 'should set up variants' do
        p.variants.size.should == 1
        v = p.variants.first
        v.sku.should == ls_v.code
        v.option_values.map(&:name).join.should match(/#{ls_v.color}/)
      end

      it 'should set up stock levels' do
        v = p.variants[0]
        v.stock_items[0].count_on_hand.should == ls_v.inventory[:available]
      end
    end
  end
end
