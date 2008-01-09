require File.dirname(__FILE__) + '/../spec_helper'

describe_access_for GroupsController do
  all { define_models :users }

  # group owner and admin
  as :default, :admin do
    it_allows(:get,  :index)
    it_allows(:get,  :new)
    it_allows(:post, :create)
    it_allows(:get,    :edit)    { {:id       => groups(:default) } }
    it_allows(:get,    :show)    { {:id       => groups(:default) } }
    it_allows(:put,    :update)  { {:id       => groups(:default) } }
    it_allows(:delete, :destroy) { {:id       => groups(:default) } }
  end
  
  as :anon, :pending, :suspended do
    it_restricts(:get,  :index)
    it_restricts(:get,  :new)
    it_restricts(:post, :create)
    it_restricts(:get,    :edit)    { {:id       => groups(:default) } }
    it_restricts(:get,    :show)    { {:id       => groups(:default) } }
    it_restricts(:put,    :update)  { {:id       => groups(:default) } }
    it_restricts(:delete, :destroy) { {:id       => groups(:default) } }
  end
end