require File.dirname(__FILE__) + '/../spec_helper'

describe_access_for StatusesController do
  all { define_models :users }
  
  # status owner and admin
  as :default, :admin do
    it_allows(:get,  :index)     { {:user_id    => users(:default)   } }
    it_allows(:get,  :index)     { {:project_id => projects(:default)} }
    it_allows(:get,  :new)       { {:user_id    => users(:default)   } }
    it_allows(:post, :create)    { {:user_id    => users(:default)   } }
    it_allows(:get,    :show)    { {:id         => statuses(:default)} }
    it_allows(:put,    :update)  { {:id         => statuses(:default)} }
    it_allows(:delete, :destroy) { {:id         => statuses(:default)} }
  end
  
  as :anon, :pending, :suspended do
    it_restricts(:get,  :index)     { {:user_id    => users(:default)   } }
    it_restricts(:get,  :index)     { {:project_id => projects(:default)} }
    it_restricts(:get,  :new)       { {:user_id    => users(:default)   } }
    it_restricts(:post, :create)    { {:user_id    => users(:default)   } }
    it_restricts(:get,    :show)    { {:id         => statuses(:default)} }
    it_restricts(:put,    :update)  { {:id         => statuses(:default)} }
    it_restricts(:delete, :destroy) { {:id         => statuses(:default)} }
  end
end