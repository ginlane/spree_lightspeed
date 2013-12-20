require 'spec_helper'

module Spree
  module Admin
    describe ProductsController do
      render_views
      stub_authorization!

      let(:ability_user) { stub_model(Spree::LegacyUser, :has_spree_role? => true) }

      before do
        controller.
          stub(:try_spree_current_user).
          and_return(ability_user)
      end

      context '#new_lightspeed_products' do
        it 'should return status 200' do
          spree_get :new_lightspeed_products

          response.status.should == 200 #should render(:new_lightspeed_products)
        end
      end
    end
  end
end
