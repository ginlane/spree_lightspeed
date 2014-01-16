module SpreeLightspeed
  class BatchProcessor
    attr_accessor :batch_id, :products, :ls_products, :ls_variants

    def initialize bid, collection
      self.batch_id = bid
      self.products = collection
      raise "Not all products have the correct :batch_id" unless products.all?{|p| p.batch_id == batch_id }
      self.ls_products = []
      self.ls_variants = []
    end

    def prepare_new_records
      products.each do |p|
        if p.variants
          self.ls_variants += new_ls_variants(p.variants)
        else
          self.ls_products << new_ls_product(p) if p.batch_id == batch_id
        end
      end
    end

    def new_ls_product product
      ls_p = Lightspeed::Product.new

      VARIANT_ATTR_MAP.merge(PRODUCT_ATTR_MAP).each do |ls_field, spree_field|
        ls_p.send("#{ls_field}=", product.send(spree_field))
      end

      ls_p
    end

    def new_ls_variants variants
      variants.map do |variant|
        next unless variant.batch_id == batch_id

        ls_v = Lightspeed::Product.new
        VARIANT_ATTR_MAP.each do |ls_field, spree_field|
          ls_v.send("#{ls_field}=", variant.send(spree_field))
        end
        ls_v
      end.compact
    end

    def collection
      ls_products + ls_variants
    end

    def link_to_spree_record record
      spree_record = Spree::Variant.find_by_sku record.code
      spree_record.update_attrbute(:ls_id, record.id)
    end

    def send_to_lightspeed!
      prepare_new_records unless collection.present?

      collection.each do |record|
        record.create
        link_to_spree_record record
      end
    end
  end
end
