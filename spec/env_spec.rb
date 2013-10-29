require 'spec_helper'

describe "Rspec environment" do
  it 'has access to a Lightspeed Product collection' do
    ls_products.size > 0
  end

  it 'has access to a detailed Lightspeed Product view' do
    ls_product(ls_products[0].id).code.should be_present
  end
end
