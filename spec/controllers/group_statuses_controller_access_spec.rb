require File.dirname(__FILE__) + '/../spec_helper'

describe_access_for GroupStatusesController do
  all { define_models :users }

  as :default do #, :admin do
    it_allows(:get,  :index)  { {:group_id => groups(:default) } }
  end

  #as :nonmember do
  #  it_restricts(:get,  :index)  { {:group_id => groups(:default) } }
  #end
  #
  #as :anon, :pending, :suspended do
  #  it_restricts(:get,  :index)  { {:group_id => groups(:default) } }
  #end
end