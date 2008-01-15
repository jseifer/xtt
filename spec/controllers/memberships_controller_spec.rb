require File.dirname(__FILE__) + '/../spec_helper'

describe MembershipsController, "POST #create" do
  define_models :users
  
  before do
    login_as :default
    @project = mock_model Project
    Project.stub!(:find).with('1').and_return(@project)
    @attributes = {:project => @project, :user => users(:nonmember)}
    @membership = mock_model Membership, :new_record? => false, :errors => []
    Membership.stub!(:new).with(@attributes).and_return(@membership)
  end
  
  describe MembershipsController, "(successful creation)" do
    define_models :users
    act! { post :create, :project_id => 1, :user_id => users(:nonmember).id, :format => 'js' }

    before do
      @membership.stub!(:save).and_return(true)
    end
    
    it_assigns :membership
    it_renders :template, :create, :format => :js
  end

  describe MembershipsController, "(unsuccessful creation)" do
    define_models :users
    act! { post :create, :project_id => 1, :user_id => users(:nonmember).id, :format => 'js' }

    before do
      @membership.stub!(:save).and_return(false)
    end
    
    it_assigns :membership
    it_renders :template, :create, :format => :js
  end
  
end

describe MembershipsController, "DELETE #destroy" do
  define_models :users
  act! { delete :destroy, :id => 1, :format => 'js' }
  
  before do
    login_as :default
    @membership = memberships(:default)
    @membership.stub!(:destroy)
    Membership.stub!(:find).with('1').and_return(@membership)
  end

  it_assigns :membership
  it_renders :template, :destroy, :format => :js
  
end