module Spree
  class ProductImporter
    attr_accessor :ls_product, :spree_product, :spree_color_option, :spree_size_option, :spree_shipping_category, :spree_taxonomy

    OPTION_TYPES = [:size, :color]
    attr_accessor *OPTION_TYPES.map{|ot| "spree_#{ot}_option"}

    # Keys represent Lightspeed fields, values hold the Spree semantic equivalents
    PRODUCT_ATTR_MAP = {
      description_copy: :name
    }

    VARIANT_ATTR_MAP = {
      sell_price: :price,
      id: :lightspeed_product_id,
      cost: :cost_price,
      code: :sku,
      height: :height,
      length: :depth,
      width: :width,
      weight: :weight
    }

    def initialize ls_object, shipping_category = nil, taxonomy = nil
      self.spree_shipping_category = shipping_category || Spree::ShippingCategory.first
      self.spree_taxonomy = taxonomy || Spree::Taxonomy.first

      self.spree_product = Spree::Product.new
      self.ls_product = ls_object
    end

    def prime_defaults
      raise "Please create a shipping category" unless spree_product.shipping_category ||= spree_shipping_category
      raise "Please create a taxonomy" unless spree_taxonomy
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

      taxon = Spree::Taxon.find_or_create_by name: category, taxonomy_id: spree_taxonomy.id
      spree_product.taxons << taxon
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
            presentation: ls_variant.send(ot).titleize,
            option_type_id: option_type.id
          )

          variant.option_values << option_value
        end

        variant.save
      end
    end

    def perform
      prime_defaults
      map_basic_attrs
      map_taxonomy
      ensure_option_types
      recreate_variants
    end
  end
end
