require File.dirname(__FILE__) + '/../spec_helper'

describe_access_for ProjectStatusesController do
  all { define_models :users }

  as :default do #, :admin do
    it_allows(:get,  :index)  { {:project_id => projects(:default) } }
  end

  as :nonmember do
    it_restricts(:get,  :index)  { {:project_id => projects(:default) } }
  end
  
  as :anon, :pending, :suspended do
    it_restricts(:get,  :index)  { {:project_id => projects(:default) } }
  end
end