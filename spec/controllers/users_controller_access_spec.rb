require File.dirname(__FILE__) + '/../spec_helper'

describe_access_for UsersController do
  before { define_models :users }

  as :anon, :default do
    it_allows :get, [:index, :new]
    it_allows :post, :create
    it_restricts :put,    [:suspend, :unsuspend], :id => 1
    it_restricts :delete, [:destroy, :purge], :id => 1
    it_performs "activates with", :get, :activate, :key => 'foo' do
      response.should redirect_to(root_path)
    end
  end
  
  as :anon do
    it_restricts :get, [:show, :edit], :id => 1
  end
  
  as :pending do
    it_performs "activates with", :get, :activate, :key => 'foo' do
      response.should redirect_to(root_path)
    end
  end
  
  as :pending, :suspended do
    it_restricts :get, [:index, :new]
    it_restricts :post, :create
    it_restricts :put,    [:suspend, :unsuspend], :id => 1
    it_restricts :delete, [:destroy, :purge], :id => 1
  end
  
  as :admin do
    it_allows :get, [:index, :new]
    it_allows :post, :create
    it_allows :put,    [:suspend, :unsuspend], :id => 1
    it_allows :delete, [:destroy, :purge], :id => 1
    it_performs "activates with", :get, :activate, :key => 'foo' do
      response.should redirect_to(root_path)
    end
  end
end