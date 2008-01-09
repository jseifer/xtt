require File.dirname(__FILE__) + '/../spec_helper'

describe_access_for UsersController do
  skip_filters :find_user
  all { define_models :users }

  as :anon, :default, :pending, :suspended do
    it_allows :get, :new
    it_allows :post, :create
    it_restricts :put,    [:suspend, :unsuspend], :id => 1
    it_restricts :delete, [:destroy, :purge], :id => 1
    it_allows :get, :activate, :key => 'foo'
  end
  
  as :anon do
    it_restricts :get, :index
    it_restricts :get, [:show, :edit], :id => 1
  end
  
  as :default do
    it_allows :get, :index
    it_allows :get, [:show, :edit], :id => 1
  end
  
  as :admin do
    it_allows :get, [:index, :new]
    it_allows :post, :create
    it_allows :put,    [:suspend, :unsuspend], :id => 1
    it_allows :delete, [:destroy, :purge], :id => 1
    it_allows :get, :activate, :key => 'foo'
  end
end