require File.dirname(__FILE__) + '/../spec_helper'

describe GroupsController, "GET #index" do
  define_models :users

  act! { get :index }

  before do
    login_as :default
    @groups = []
    @user.stub!(:groups).and_return(@groups)
  end
  
  it_assigns :groups
  it_renders :template, :index

  describe GroupsController, "(xml)" do
    define_models :users
    
    act! { get :index, :format => 'xml' }

    it_assigns :groups
    it_renders :xml, :groups
  end

end

describe GroupsController, "GET #show" do
  define_models :users

  act! { get :show, :id => 1 }

  before do
    login_as :default
    @group  = groups(:default)
    Group.stub!(:find).with('1').and_return(@group)
  end
  
  it_assigns :group
  it_renders :template, :show
  
  describe GroupsController, "(xml)" do
    define_models :users
    
    act! { get :show, :id => 1, :format => 'xml' }

    it_renders :xml, :group
  end


end

describe GroupsController, "GET #new" do
  define_models :users
  act! { get :new }
  before do
    login_as :default
    @group  = Group.new
  end

  it "assigns @group" do
    act!
    assigns[:group].should be_new_record
  end
  
  it_renders :template, :new
  
  describe GroupsController, "(xml)" do
    define_models :users
    act! { get :new, :format => 'xml' }

    it_renders :xml, :group
  end


end

describe GroupsController, "GET #edit" do
  define_models :users
  act! { get :edit, :id => 1 }
  
  before do
    login_as :default
    @group  = groups(:default)
    Group.stub!(:find).with('1').and_return(@group)
  end

  it_assigns :group
  it_renders :template, :edit
end

describe GroupsController, "POST #create" do
  before do
    login_as :default
    @attributes = {}
    @group = mock_model Group, :new_record? => false, :errors => []
    @user.owned_groups.stub!(:build).with(@attributes).and_return(@group)
  end
  
  describe GroupsController, "(successful creation)" do
    define_models :users
    act! { post :create, :group => @attributes }

    before do
      @group.stub!(:save).and_return(true)
    end
    
    it_assigns :group, :flash => { :notice => :not_nil }
    it_redirects_to { group_path(@group) }
  end

  describe GroupsController, "(unsuccessful creation)" do
    define_models :users
    act! { post :create, :group => @attributes }

    before do
      @group.stub!(:save).and_return(false)
    end
    
    it_assigns :group
    it_renders :template, :new
  end
  
  describe GroupsController, "(successful creation, xml)" do
    define_models :users
    act! { post :create, :group => @attributes, :format => 'xml' }

    before do
      @group.stub!(:save).and_return(true)
      @group.stub!(:to_xml).and_return("mocked content")
    end
    
    it_assigns :group, :headers => { :Location => lambda { group_url(@group) } }
    it_renders :xml, :group, :status => :created
  end
  
  describe GroupsController, "(unsuccessful creation, xml)" do
    define_models :users
    act! { post :create, :group => @attributes, :format => 'xml' }

    before do
      @group.stub!(:save).and_return(false)
    end
    
    it_assigns :group
    it_renders :xml, "group.errors", :status => :unprocessable_entity
  end

end

describe GroupsController, "PUT #update" do
  before do
    login_as :default
    @attributes = {}
    @group = groups(:default)
    Group.stub!(:find).with('1').and_return(@group)
  end
  
  describe GroupsController, "(successful save)" do
    define_models :users
    act! { put :update, :id => 1, :group => @attributes }

    before do
      @group.stub!(:save).and_return(true)
    end
    
    it_assigns :group, :flash => { :notice => :not_nil }
    it_redirects_to { group_path(@group) }
  end

  describe GroupsController, "(unsuccessful save)" do
    define_models :users
    act! { put :update, :id => 1, :group => @attributes }

    before do
      @group.stub!(:save).and_return(false)
    end
    
    it_assigns :group
    it_renders :template, :edit
  end
  
  describe GroupsController, "(successful save, xml)" do
    define_models :users
    act! { put :update, :id => 1, :group => @attributes, :format => 'xml' }

    before do
      @group.stub!(:save).and_return(true)
    end
    
    it_assigns :group
    it_renders :blank
  end
  
  describe GroupsController, "(unsuccessful save, xml)" do
    define_models :users
    act! { put :update, :id => 1, :group => @attributes, :format => 'xml' }

    before do
      @group.stub!(:save).and_return(false)
    end
    
    it_assigns :group
    it_renders :xml, "group.errors", :status => :unprocessable_entity
  end

end

describe GroupsController, "DELETE #destroy" do
  define_models :users
  act! { delete :destroy, :id => 1 }
  
  before do
    login_as :default
    @group = groups(:default)
    @group.stub!(:destroy)
    Group.stub!(:find).with('1').and_return(@group)
  end

  it_assigns :group
  it_redirects_to { groups_path }
  
  describe GroupsController, "(xml)" do
    define_models :users
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it_assigns :group
    it_renders :blank
  end

end