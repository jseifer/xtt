require File.dirname(__FILE__) + '/../spec_helper'

# USER SCOPE

describe StatusesController, "GET #index for user" do
  define_models

  act! { get :index, :format => 'xml' }

  before do
    @statuses = [statuses(:default)]
    login_as :default
    @user.stub!(:statuses).and_return(@statuses)
  end
  
  it_assigns :statuses
  it_renders :xml, :statuses
end

describe StatusesController, "GET #new" do
  define_models
  act! { get :new }
  before do
    @status  = Status.new
    controller.stub!(:login_required)
  end

  it "assigns @status" do
    act!
    assigns[:status].should be_new_record
  end
  
  it_renders :template, :new
  
  describe StatusesController, "(xml)" do
    define_models
    act! { get :new, :format => 'xml' }

    it_renders :xml, :status
  end
end

describe StatusesController, "POST #create" do
  before do
    @attributes = {'message' => 'foo'}
    @status = Status.new(@attributes)
    login_as :default
    @user.stub!(:post).with('foo', nil).and_return(@status)
    @user.statuses.stub!(:before).and_return(nil)
    @status.user = @user
  end
  
  describe StatusesController, "(successful creation)" do
    define_models
    act! { post :create, :status => @attributes }
    
    before { @status.stub!(:new_record?).and_return(false) }
    
    it_assigns :status
    it_redirects_to { root_path }
  end
  
  describe StatusesController, "(successful creation with forced project" do
    define_models
    act! { post :create, :status => @attributes }
    
    before do
      @user.stub!(:projects).and_return([])
      @user.projects.stub!(:find_by_id).with(projects(:default).id.to_s).and_return(projects(:default))
      @attributes['project_id'] = projects(:default).id.to_s
      @user.should_receive(:post).with('foo', projects(:default)).and_return(@status)
      @status.stub!(:new_record?).and_return(false)
    end
    
    it_assigns :status
    it_redirects_to { project_path(projects(:default)) }
  end

  describe StatusesController, "(unsuccessful creation)" do
    define_models
    act! { post :create, :status => @attributes }

    before do
      @status.message = nil
      controller.stub!(:login_required)
    end
    
    it_assigns :status
    it_renders :template, :new
  end
  
  describe StatusesController, "(successful creation, xml)" do
    define_models
    act! { post :create, :status => @attributes, :format => 'xml' }

    before { @status.stub!(:new_record?).and_return(false) }
    
    it_assigns :status, :headers => { :Location => lambda { status_url(@status) } }
    it_renders :xml, :status, :status => :created
  end
  
  describe StatusesController, "(unsuccessful creation, xml)" do
    define_models
    act! { post :create, :status => @attributes, :format => 'xml' }

    before do
      @status.message = nil
      controller.stub!(:login_required)
    end
    
    it_assigns :status
    it_renders :xml, "status.errors", :status => :unprocessable_entity
  end
end

# GLOBAL SCOPE

describe StatusesController, "GET #show" do
  define_models

  act! { get :show, :id => 1 }

  before do
    @status  = statuses(:default)
    Status.stub!(:find).with('1').and_return(@status)
    controller.stub!(:login_required)
  end
  
  it_assigns :status
  it_renders :template, :show
  
  describe StatusesController, "(xml)" do
    define_models
    
    act! { get :show, :id => 1, :format => 'xml' }

    it_renders :xml, :status
  end
end

describe StatusesController, "PUT #update" do
  before do
    @attributes = {}
    @status = statuses(:default)
    Status.stub!(:find).with('1').and_return(@status)
    controller.stub!(:login_required)
  end
  
  describe StatusesController, "(successful save)" do
    define_models
    act! { put :update, :id => 1, :status => @attributes }

    before do
      @status.stub!(:save).and_return(true)
      controller.stub!(:login_required)
    end
    
    it_assigns :status, :flash => { :notice => :not_nil }
    it_redirects_to { status_path(@status) }
  end

  describe StatusesController, "(unsuccessful save)" do
    define_models
    act! { put :update, :id => 1, :status => @attributes }

    before do
      @status.stub!(:save).and_return(false)
      controller.stub!(:login_required)
    end
    
    it_assigns :status
    it_renders :template, :edit
  end
  
  describe StatusesController, "(successful save, xml)" do
    define_models
    act! { put :update, :id => 1, :status => @attributes, :format => 'xml' }

    before do
      @status.stub!(:save).and_return(true)
      controller.stub!(:login_required)
    end
    
    it_assigns :status
    it_renders :blank
  end
  
  describe StatusesController, "(unsuccessful save, xml)" do
    define_models
    act! { put :update, :id => 1, :status => @attributes, :format => 'xml' }

    before do
      @status.stub!(:save).and_return(false)
      controller.stub!(:login_required)
    end
    
    it_assigns :status
    it_renders :xml, "status.errors", :status => :unprocessable_entity
  end
end

describe StatusesController, "DELETE #destroy" do
  define_models
  act! { delete :destroy, :id => 1 }
  
  before do
    @status = statuses(:default)
    @status.stub!(:destroy)
    Status.stub!(:find).with('1').and_return(@status)
    controller.stub!(:login_required)
  end

  it_assigns :status
  it_redirects_to { statuses_path }
  
  describe StatusesController, "(xml)" do
    define_models
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it_assigns :status
    it_renders :blank
  end
end