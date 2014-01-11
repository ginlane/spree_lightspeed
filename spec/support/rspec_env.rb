module RspecEnv
  def ls_products opts = {}
    VCR.use_cassette("lightspeed products for opts: #{opts.keys.presence || 'def'}") do
      our_opts = opts.dup
      our_opts[:filters] ||= {}
      our_opts[:filters][:master_model_eq] = 1
      Lightspeed::Product.all our_opts
    end
  end

  def ls_variants id, opts = {}
    p = ls_product id
    VCR.use_cassette("lightspeed variants for #{id}") do
      p.variants
    end
  end

  def ls_product id, opts = {}
    VCR.use_cassette("lightspeed product details #{id}") do
      Lightspeed::Product.find(id, opts)
    end
  end

  def ls_product_by_sku sku
    Lightspeed::Product.all(
      filters: {code_eq: sku}
    )
  end

end
