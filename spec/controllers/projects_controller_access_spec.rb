require File.dirname(__FILE__) + '/../spec_helper'

describe_access_for ProjectsController do
  all { define_models :users }

  # project owner and admin
  as :default, :admin do
    it_allows(:get,    :index)
    it_allows(:get,    :new)
    it_allows(:post,   :create)
    it_allows(:get,    :edit)    { {:id => projects(:user) } }
    it_allows(:get,    :show)    { {:id => projects(:user) } }
    it_allows(:put,    :update)  { {:id => projects(:user) } }
    it_allows(:delete, :destroy) { {:id => projects(:user) } }
  end
  
  as :nonmember do
    it_allows(:get,       :index)
    it_allows(:get,       :new)
    it_allows(:post,      :create)
    it_restricts(:get,    :edit)    { {:id => projects(:user) } }
    it_restricts(:get,    :show)    { {:id => projects(:user) } }
    it_restricts(:put,    :update)  { {:id => projects(:user) } }
    it_restricts(:delete, :destroy) { {:id => projects(:user) } }
  end
  
  as :anon, :pending, :suspended do
    it_restricts(:get,    :index)
    it_restricts(:get,    :new)
    it_restricts(:post,   :create)
    it_restricts(:get,    :edit)    { {:id => projects(:user) } }
    it_restricts(:get,    :show)    { {:id => projects(:user) } }
    it_restricts(:put,    :update)  { {:id => projects(:user) } }
    it_restricts(:delete, :destroy) { {:id => projects(:user) } }
  end
end