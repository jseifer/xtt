require File.dirname(__FILE__) + '/../spec_helper'

describe_access_for StatusesController do
  before { define_models :users }

  as :default, :admin do
    it_allows :get, [:index, :new]
    it_allows :post, :create
    it_allows :put,    :update, :id => 1
    it_allows :delete, :destroy, :id => 1
  end
  
  as :anon, :pending, :suspended do
    it_restricts :get, [:index, :new]
    it_restricts :post, :create
    it_restricts :put,    :update, :id => 1
    it_restricts :delete, :destroy, :id => 1
  end
end