require File.dirname(__FILE__) + '/../spec_helper'

describe GroupsController, "GET #index" do
  # fixture definition

  act! { get :index }

  before do
    @groups = []
    Group.stub!(:find).with(:all).and_return(@groups)
  end
  
  it.assigns :groups
  it.renders :template, :index

  describe GroupsController, "(xml)" do
    # fixture definition
    
    act! { get :index, :format => 'xml' }

    it.assigns :groups
    it.renders :xml, :groups
  end

end

describe GroupsController, "GET #show" do
  # fixture definition

  act! { get :show, :id => 1 }

  before do
    @group  = groups(:default)
    Group.stub!(:find).with('1').and_return(@group)
  end
  
  it.assigns :group
  it.renders :template, :show
  
  describe GroupsController, "(xml)" do
    # fixture definition
    
    act! { get :show, :id => 1, :format => 'xml' }

    it.renders :xml, :group
  end


end

describe GroupsController, "GET #new" do
  # fixture definition
  act! { get :new }
  before do
    @group  = Group.new
  end

  it "assigns @group" do
    act!
    assigns[:group].should be_new_record
  end
  
  it.renders :template, :new
  
  describe GroupsController, "(xml)" do
    # fixture definition
    act! { get :new, :format => 'xml' }

    it.renders :xml, :group
  end


end

describe GroupsController, "GET #edit" do
  # fixture definition
  act! { get :edit, :id => 1 }
  
  before do
    @group  = groups(:default)
    Group.stub!(:find).with('1').and_return(@group)
  end

  it.assigns :group
  it.renders :template, :edit
end

describe GroupsController, "POST #create" do
  before do
    @attributes = {}
    @group = mock_model Group, :new_record? => false, :errors => []
    Group.stub!(:new).with(@attributes).and_return(@group)
  end
  
  describe GroupsController, "(successful creation)" do
    # fixture definition
    act! { post :create, :group => @attributes }

    before do
      @group.stub!(:save).and_return(true)
    end
    
    it.assigns :group, :flash => { :notice => :not_nil }
    it.redirects_to { group_path(@group) }
  end

  describe GroupsController, "(unsuccessful creation)" do
    # fixture definition
    act! { post :create, :group => @attributes }

    before do
      @group.stub!(:save).and_return(false)
    end
    
    it.assigns :group
    it.renders :template, :new
  end
  
  describe GroupsController, "(successful creation, xml)" do
    # fixture definition
    act! { post :create, :group => @attributes, :format => 'xml' }

    before do
      @group.stub!(:save).and_return(true)
      @group.stub!(:to_xml).and_return("mocked content")
    end
    
    it.assigns :group, :headers => { :Location => lambda { group_url(@group) } }
    it.renders :xml, :group, :status => :created
  end
  
  describe GroupsController, "(unsuccessful creation, xml)" do
    # fixture definition
    act! { post :create, :group => @attributes, :format => 'xml' }

    before do
      @group.stub!(:save).and_return(false)
    end
    
    it.assigns :group
    it.renders :xml, "group.errors", :status => :unprocessable_entity
  end

end

describe GroupsController, "PUT #update" do
  before do
    @attributes = {}
    @group = groups(:default)
    Group.stub!(:find).with('1').and_return(@group)
  end
  
  describe GroupsController, "(successful save)" do
    # fixture definition
    act! { put :update, :id => 1, :group => @attributes }

    before do
      @group.stub!(:save).and_return(true)
    end
    
    it.assigns :group, :flash => { :notice => :not_nil }
    it.redirects_to { group_path(@group) }
  end

  describe GroupsController, "(unsuccessful save)" do
    # fixture definition
    act! { put :update, :id => 1, :group => @attributes }

    before do
      @group.stub!(:save).and_return(false)
    end
    
    it.assigns :group
    it.renders :template, :edit
  end
  
  describe GroupsController, "(successful save, xml)" do
    # fixture definition
    act! { put :update, :id => 1, :group => @attributes, :format => 'xml' }

    before do
      @group.stub!(:save).and_return(true)
    end
    
    it.assigns :group
    it.renders :blank
  end
  
  describe GroupsController, "(unsuccessful save, xml)" do
    # fixture definition
    act! { put :update, :id => 1, :group => @attributes, :format => 'xml' }

    before do
      @group.stub!(:save).and_return(false)
    end
    
    it.assigns :group
    it.renders :xml, "group.errors", :status => :unprocessable_entity
  end

end

describe GroupsController, "DELETE #destroy" do
  # fixture definition
  act! { delete :destroy, :id => 1 }
  
  before do
    @group = groups(:default)
    @group.stub!(:destroy)
    Group.stub!(:find).with('1').and_return(@group)
  end

  it.assigns :group
  it.redirects_to { groups_path }
  
  describe GroupsController, "(xml)" do
    # fixture definition
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it.assigns :group
    it.renders :blank
  end

end