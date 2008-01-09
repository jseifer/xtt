require File.dirname(__FILE__) + '/../spec_helper'

describe_access_for UsersController do
  before { define_models :users }

  as :anon, :default do
    it_allows :post, :create
    it_allows :get, [:index, :new]
    it_restricts :put,    [:suspend, :unsuspend], :id => 1
    it_restricts :delete, [:destroy, :purge], :id => 1
  end
  
  as :anon do
    it_restricts :get, [:show, :edit], :id => 1
  end
end