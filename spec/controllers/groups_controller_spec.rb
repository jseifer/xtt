require File.dirname(__FILE__) + '/../spec_helper'

describe GroupsController, "GET #index" do
  define_models

  act! { get :index }

  before do
    @groups = []
    Group.stub!(:find).with(:all).and_return(@groups)
    controller.stub!(:login_required)
  end
  
  it_assigns :groups
  it_renders :template, :index
end

describe GroupsController, "GET #show" do
  define_models

  act! { get :show, :id => 1 }

  before do
    @group  = groups(:default)
    Group.stub!(:find).with('1').and_return(@group)
    controller.stub!(:login_required)
  end
  
  it_assigns :group
  it_renders :template, :show
end

describe GroupsController, "GET #new" do
  define_models
  act! { get :new }
  before do
    @group  = Group.new
    controller.stub!(:login_required)
  end

  it "assigns @group" do
    act!
    assigns[:group].should be_new_record
  end
  
  it_renders :template, :new
end

describe GroupsController, "GET #edit" do
  define_models
  act! { get :edit, :id => 1 }
  
  before do
    @group  = groups(:default)
    Group.stub!(:find).with('1').and_return(@group)
    controller.stub!(:login_required)
  end

  it_assigns :group
  it_renders :template, :edit
end

describe GroupsController, "POST #create" do
  before do
    @attributes = {}
    @group = mock_model Group, :new_record? => false, :errors => []
    Group.stub!(:new).with(@attributes).and_return(@group)
    controller.stub!(:login_required)
  end
  
  describe GroupsController, "(successful creation)" do
    define_models
    act! { post :create, :group => @attributes }

    before do
      @group.stub!(:save).and_return(true)
      controller.stub!(:login_required)
    end
    
    it_assigns :group, :flash => { :notice => :not_nil }
    it_redirects_to { group_path(@group) }
  end

  describe GroupsController, "(unsuccessful creation)" do
    define_models
    act! { post :create, :group => @attributes }

    before do
      @group.stub!(:save).and_return(false)
      controller.stub!(:login_required)
    end
    
    it_assigns :group
    it_renders :template, :new
  end
end

describe GroupsController, "PUT #update" do
  before do
    @attributes = {}
    @group = groups(:default)
    Group.stub!(:find).with('1').and_return(@group)
    controller.stub!(:login_required)
  end
  
  describe GroupsController, "(successful save)" do
    define_models
    act! { put :update, :id => 1, :group => @attributes }

    before do
      @group.stub!(:save).and_return(true)
      controller.stub!(:login_required)
    end
    
    it_assigns :group, :flash => { :notice => :not_nil }
    it_redirects_to { group_path(@group) }
  end

  describe GroupsController, "(unsuccessful save)" do
    define_models
    act! { put :update, :id => 1, :group => @attributes }

    before do
      @group.stub!(:save).and_return(false)
      controller.stub!(:login_required)
    end
    
    it_assigns :group
    it_renders :template, :edit
  end
end

describe GroupsController, "DELETE #destroy" do
  define_models
  act! { delete :destroy, :id => 1 }
  
  before do
    @group = groups(:default)
    @group.stub!(:destroy)
    Group.stub!(:find).with('1').and_return(@group)
    controller.stub!(:login_required)
  end

  it_assigns :group
  it_redirects_to { groups_path }
end