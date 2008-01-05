require File.dirname(__FILE__) + '/../spec_helper'

# USER SCOPE

describe StatusesController, "GET #index" do
  define_models

  act! { get :index, :user_id => users(:default).id }

  before do
    @statuses = [statuses(:default)]
  end
  
  it.assigns :statuses
  it.renders :template, :index

  describe StatusesController, "(xml)" do
    define_models
    
    act! { get :index, :user_id => users(:default).id, :format => 'xml' }

    it.assigns :statuses
    it.renders :xml, :statuses
  end
end

describe StatusesController, "GET #new" do
  define_models
  act! { get :new, :user_id => users(:default).id }
  before do
    @status  = Status.new
  end

  it "assigns @status" do
    act!
    assigns[:status].should be_new_record
  end
  
  it.renders :template, :new
  
  describe StatusesController, "(xml)" do
    define_models
    act! { get :new, :user_id => users(:default).id, :format => 'xml' }

    it.renders :xml, :status
  end
end

describe StatusesController, "POST #create" do
  before do
    @attributes = {:message => 'foo'}
    @status = Status.new(@attributes)
    @user = users(:default)
    @user.stub!(:statuses).and_return([])
    @user.statuses.stub!(:build).and_return(@status)
    @status.user = @user
    User.stub!(:find).with(@user.id.to_s).and_return(@user)
  end
  
  describe StatusesController, "(successful creation)" do
    define_models
    act! { post :create, :user_id => users(:default).id, :status => @attributes }
    
    it.assigns :user, :status, :flash => { :notice => :not_nil }
    it.redirects_to { user_statuses_path(@user) }
  end

  describe StatusesController, "(unsuccessful creation)" do
    define_models
    act! { post :create, :user_id => users(:default).id, :status => @attributes }

    before do
      @status.message = nil
    end
    
    it.assigns :user, :status
    it.renders :template, :new
  end
  
  describe StatusesController, "(successful creation, xml)" do
    define_models
    act! { post :create, :user_id => users(:default).id, :status => @attributes, :format => 'xml' }
    
    it.assigns :user, :status, :headers => { :Location => lambda { status_url(@status) } }
    it.renders :xml, :status, :status => :created
  end
  
  describe StatusesController, "(unsuccessful creation, xml)" do
    define_models
    act! { post :create, :user_id => users(:default).id, :status => @attributes, :format => 'xml' }

    before do
      @status.message = nil
    end
    
    it.assigns :user, :status
    it.renders :xml, "status.errors", :status => :unprocessable_entity
  end
end

# GLOBAL SCOPE

describe StatusesController, "GET #show" do
  define_models

  act! { get :show, :id => 1 }

  before do
    @status  = statuses(:default)
    Status.stub!(:find).with('1').and_return(@status)
  end
  
  it.assigns :status
  it.renders :template, :show
  
  describe StatusesController, "(xml)" do
    define_models
    
    act! { get :show, :id => 1, :format => 'xml' }

    it.renders :xml, :status
  end
end

describe StatusesController, "GET #edit" do
  define_models
  act! { get :edit, :id => 1 }
  
  before do
    @status  = statuses(:default)
    Status.stub!(:find).with('1').and_return(@status)
  end

  it.assigns :status
  it.renders :template, :edit
end

describe StatusesController, "PUT #update" do
  before do
    @attributes = {}
    @status = statuses(:default)
    Status.stub!(:find).with('1').and_return(@status)
  end
  
  describe StatusesController, "(successful save)" do
    define_models
    act! { put :update, :id => 1, :status => @attributes }

    before do
      @status.stub!(:save).and_return(true)
    end
    
    it.assigns :status, :flash => { :notice => :not_nil }
    it.redirects_to { status_path(@status) }
  end

  describe StatusesController, "(unsuccessful save)" do
    define_models
    act! { put :update, :id => 1, :status => @attributes }

    before do
      @status.stub!(:save).and_return(false)
    end
    
    it.assigns :status
    it.renders :template, :edit
  end
  
  describe StatusesController, "(successful save, xml)" do
    define_models
    act! { put :update, :id => 1, :status => @attributes, :format => 'xml' }

    before do
      @status.stub!(:save).and_return(true)
    end
    
    it.assigns :status
    it.renders :blank
  end
  
  describe StatusesController, "(unsuccessful save, xml)" do
    define_models
    act! { put :update, :id => 1, :status => @attributes, :format => 'xml' }

    before do
      @status.stub!(:save).and_return(false)
    end
    
    it.assigns :status
    it.renders :xml, "status.errors", :status => :unprocessable_entity
  end
end

describe StatusesController, "DELETE #destroy" do
  define_models
  act! { delete :destroy, :id => 1 }
  
  before do
    @status = statuses(:default)
    @status.stub!(:destroy)
    Status.stub!(:find).with('1').and_return(@status)
  end

  it.assigns :status
  it.redirects_to { statuses_path }
  
  describe StatusesController, "(xml)" do
    define_models
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it.assigns :status
    it.renders :blank
  end
end