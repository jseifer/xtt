require File.dirname(__FILE__) + '/../spec_helper'

describe_access_for GroupProjectsController do
  all { define_models :users }

  as :default, :admin do
    it_allows(:get,  :index)  { {:group_id => groups(:default) } }
    it_allows(:get,  :new)    { {:group_id => groups(:default) } }
    it_allows(:post, :create) { {:group_id => groups(:default) } }
  end

  as :nonmember do
    it_restricts(:get,  :index)  { {:group_id => groups(:default) } }
    it_restricts(:get,  :new)    { {:group_id => groups(:default) } }
    it_restricts(:post, :create) { {:group_id => groups(:default) } }
  end

  as :anon, :pending, :suspended do
    it_restricts(:get,  :index)  { {:group_id => groups(:default) } }
    it_restricts(:get,  :new)    { {:group_id => groups(:default) } }
    it_restricts(:post, :create) { {:group_id => groups(:default) } }
  end
end