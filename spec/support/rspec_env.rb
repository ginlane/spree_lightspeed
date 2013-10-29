module RspecEnv
  def ls_products opts = {}
    VCR.use_cassette('lightspeed product collection') do
      Lightspeed::Product.all opts
    end
  end

  def ls_product id, opts = {}
    VCR.use_cassette("lightspeed product details #{id}") do
      Lightspeed::Product.find(id, opts)
    end
  end
end
