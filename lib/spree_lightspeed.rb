require 'spree/core'
require 'spree_lightspeed/engine'
require 'spree_lightspeed/batch_processor'
require "spree_lightspeed/product_importer"

module SpreeLightspeed
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
end
