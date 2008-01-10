require File.dirname(__FILE__) + '/../spec_helper'

describe MembershipsController, "POST #create" do
  define_models :users
  
  before do
    login_as :default
    @attributes = {}
    @group = mock_model Group
    @user.groups.stub!(:find).with(1).and_return(@group)
    @membership = mock_model Membership, :new_record? => false, :errors => []
    Membership.stub!(:new).with(@attributes).and_return(@membership)
  end
  
  describe MembershipsController, "(successful creation)" do
    # fixture definition
    act! { post :create, :group_id => 1, :user_id => users(:nonmember).id, :membership => @attributes }

    before do
      @membership.stub!(:save).and_return(true)
    end
    
    it_assigns :membership, :flash => { :notice => :not_nil }
    it_redirects_to { group_membership_path(@group, @membership) }
  end

  describe MembershipsController, "(unsuccessful creation)" do
    # fixture definition
    act! { post :create, :membership => @attributes }

    before do
      @membership.stub!(:save).and_return(false)
    end
    
    it_assigns :membership
    it_renders :template, :new
  end
  
end

describe MembershipsController, "DELETE #destroy" do
  # fixture definition
  act! { delete :destroy, :group_id => 1, :id => 1 }
  
  before do
    @membership = memberships(:default)
    @membership.stub!(:destroy)
    Membership.stub!(:find).with('1').and_return(@membership)
  end

  it_assigns :membership
  it_redirects_to { group_memberships_path(@group) }
  
end