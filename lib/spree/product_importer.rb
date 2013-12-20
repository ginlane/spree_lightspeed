module Spree
  class ProductImporter
    attr_accessor :ls_product, :spree_product, :spree_color_option, :spree_size_option, :spree_shipping_category, :spree_stock_location

    TAXONOMY_NAME = 'Lightspeed Class'
    OPTION_TYPES = [:size, :color]
    attr_accessor *OPTION_TYPES.map{|ot| "spree_#{ot}_option"}

    # Keys represent Lightspeed fields, values hold the Spree semantic equivalents
    PRODUCT_ATTR_MAP = {
      description_copy: :name
    }

    VARIANT_ATTR_MAP = {
      sell_price: :price,
      id: :ls_id,
      cost: :cost_price,
      code: :sku,
      height: :height,
      length: :depth,
      width: :width,
      weight: :weight
    }

    class << self
      def new_records lightspeed_records
        return lightspeed_records if Spree::Product.count == 0

        delta = []
        lightspeed_records.each do |ls_p|
          next if Spree::Variant.find_by(ls_id: ls_p.id)
          delta << ls_p
        end
        delta
      end

      def import_delta!
        new_records(Lightspeed::Product.master_records).each do |new_ls_p|
          new(new_ls_p).perform
        end
      end
    end

    def initialize ls_object, shipping_category = nil, stock_location = nil
      self.spree_shipping_category = shipping_category || Spree::ShippingCategory.first
      self.spree_stock_location = stock_location || Spree::StockLocation.first

      self.spree_product = Spree::Product.new(available_on: Time.now)
      self.ls_product = ls_object
    end

    def lightspeed_taxonomy
      @lightspeed_taxonomy ||= Spree::Taxonomy.find_or_create_by(name: TAXONOMY_NAME)
    end

    def prime_defaults
      raise "Please create a shipping category" unless spree_product.shipping_category ||= spree_shipping_category
      raise "Please create a stock location" unless spree_stock_location
    end

    def map_basic_attrs
      VARIANT_ATTR_MAP.merge(PRODUCT_ATTR_MAP).each do |ls_field, spree_field|
        spree_product.send("#{spree_field}=", ls_product.send(ls_field))
      end

      raise "Insufficient data for a valid product: #{spree_product.errors.full_messages.join(', ')}" unless spree_product.save
    end

    def ensure_option_types
      OPTION_TYPES.each do |ot|
        option_type = Spree::OptionType.find_or_create_by(name: ot, presentation: ot.to_s.titleize)
        self.send("spree_#{ot}_option=", option_type)
        spree_product.option_types << option_type
      end
    end

    def map_taxonomy
      category = ls_product.category_name
      return unless category

      taxon = Spree::Taxon.find_or_create_by(
        name: category,
        taxonomy_id: lightspeed_taxonomy.id,
        parent_id: lightspeed_taxonomy.root.id
      )

      spree_product.taxons << taxon
    end

    def set_up_stock spree_variant, ls_variant
      stock_movement = spree_stock_location.stock_movements.build(
        quantity: ls_variant.inventory[:available]
      )
      stock_movement.stock_item = spree_stock_location.set_up_stock_item(spree_variant)
      stock_movement.save
    end

    def recreate_variants
      ls_product.loaded_variants.each do |ls_variant|
        variant = spree_product.variants.build

        VARIANT_ATTR_MAP.each do |ls_field, spree_field|
          variant.send("#{spree_field}=", ls_variant.send(ls_field))
        end

        OPTION_TYPES.each do |ot|
          option_type = self.send("spree_#{ot}_option")
          option_value = Spree::OptionValue.find_or_create_by(
            name: ls_variant.send(ot),
            presentation: ls_variant.send(ot).to_s.titleize,
            option_type_id: option_type.id
          )

          variant.option_values << option_value
        end

        variant.save && set_up_stock(variant, ls_variant)
      end
    end

    def perform
      prime_defaults

      ActiveRecord::Base.transaction do
        map_basic_attrs
        map_taxonomy
        ensure_option_types
        recreate_variants
      end
    end
  end
end
