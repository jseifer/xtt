require File.dirname(__FILE__) + '/../spec_helper'

describe_access_for ProjectsController do
  all { define_models :users }

  # project owner and admin
  as :default, :admin do
    it_allows(:get,  :index)
    it_allows(:get,  :new)       { {:user_id  => users(:default)    } }
    it_allows(:post, :create)    { {:user_id  => users(:default)    } }
    it_allows(:get,  :new)       { {:group_id => groups(:default)   } }
    it_allows(:post, :create)    { {:group_id => groups(:default)   } }
    it_allows(:get,    :edit)    { {:id       => projects(:default) } }
    it_allows(:get,    :show)    { {:id       => projects(:default) } }
    it_allows(:put,    :update)  { {:id       => projects(:default) } }
    it_allows(:delete, :destroy) { {:id       => projects(:default) } }
  end
  
  as :anon, :pending, :suspended do
    it_restricts(:get,  :index)
    it_restricts(:get,  :new)       { {:user_id  => users(:default)    } }
    it_restricts(:post, :create)    { {:user_id  => users(:default)    } }
    it_restricts(:get,  :new)       { {:group_id => groups(:default)   } }
    it_restricts(:post, :create)    { {:group_id => groups(:default)   } }
    it_restricts(:get,    :edit)    { {:id       => projects(:default) } }
    it_restricts(:get,    :show)    { {:id       => projects(:default) } }
    it_restricts(:put,    :update)  { {:id       => projects(:default) } }
    it_restricts(:delete, :destroy) { {:id       => projects(:default) } }
  end
end