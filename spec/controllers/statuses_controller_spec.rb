require File.dirname(__FILE__) + '/../spec_helper'

describe StatusesController, "GET #index" do
  define_models :statuses

  act! { get :index }

  before do
    @statuses = []
    Status.stub!(:find).with(:all).and_return(@statuses)
  end
  
  it.assigns :statuses
  it.renders :template, :index

  describe StatusesController, "(xml)" do
    define_models :statuses
    
    act! { get :index, :format => 'xml' }

    it.assigns :statuses
    it.renders :xml, :statuses
  end
end

describe StatusesController, "GET #show" do
  define_models :statuses

  act! { get :show, :id => 1 }

  before do
    @status  = statuses(:default)
    Status.stub!(:find).with('1').and_return(@status)
  end
  
  it.assigns :status
  it.renders :template, :show
  
  describe StatusesController, "(xml)" do
    define_models :statuses
    
    act! { get :show, :id => 1, :format => 'xml' }

    it.renders :xml, :status
  end
end

describe StatusesController, "GET #new" do
  define_models :statuses
  act! { get :new }
  before do
    @status  = Status.new
  end

  it "assigns @status" do
    act!
    assigns[:status].should be_new_record
  end
  
  it.renders :template, :new
  
  describe StatusesController, "(xml)" do
    define_models :statuses
    act! { get :new, :format => 'xml' }

    it.renders :xml, :status
  end
end

describe StatusesController, "GET #edit" do
  define_models :statuses
  act! { get :edit, :id => 1 }
  
  before do
    @status  = statuses(:default)
    Status.stub!(:find).with('1').and_return(@status)
  end

  it.assigns :status
  it.renders :template, :edit
end

describe StatusesController, "POST #create" do
  before do
    @attributes = {}
    @status = mock_model Status, :new_record? => false, :errors => []
    Status.stub!(:new).with(@attributes).and_return(@status)
  end
  
  describe StatusesController, "(successful creation)" do
    define_models :statuses
    act! { post :create, :status => @attributes }

    before do
      @status.stub!(:save).and_return(true)
    end
    
    it.assigns :status, :flash => { :notice => :not_nil }
    it.redirects_to { status_path(@status) }
  end

  describe StatusesController, "(unsuccessful creation)" do
    define_models :statuses
    act! { post :create, :status => @attributes }

    before do
      @status.stub!(:save).and_return(false)
    end
    
    it.assigns :status
    it.renders :template, :new
  end
  
  describe StatusesController, "(successful creation, xml)" do
    define_models :statuses
    act! { post :create, :status => @attributes, :format => 'xml' }

    before do
      @status.stub!(:save).and_return(true)
      @status.stub!(:to_xml).and_return("mocked content")
    end
    
    it.assigns :status, :headers => { :Location => lambda { status_url(@status) } }
    it.renders :xml, :status, :status => :created
  end
  
  describe StatusesController, "(unsuccessful creation, xml)" do
    define_models :statuses
    act! { post :create, :status => @attributes, :format => 'xml' }

    before do
      @status.stub!(:save).and_return(false)
    end
    
    it.assigns :status
    it.renders :xml, "status.errors", :status => :unprocessable_entity
  end
end

describe StatusesController, "PUT #update" do
  before do
    @attributes = {}
    @status = statuses(:default)
    Status.stub!(:find).with('1').and_return(@status)
  end
  
  describe StatusesController, "(successful save)" do
    define_models :statuses
    act! { put :update, :id => 1, :status => @attributes }

    before do
      @status.stub!(:save).and_return(true)
    end
    
    it.assigns :status, :flash => { :notice => :not_nil }
    it.redirects_to { status_path(@status) }
  end

  describe StatusesController, "(unsuccessful save)" do
    define_models :statuses
    act! { put :update, :id => 1, :status => @attributes }

    before do
      @status.stub!(:save).and_return(false)
    end
    
    it.assigns :status
    it.renders :template, :edit
  end
  
  describe StatusesController, "(successful save, xml)" do
    define_models :statuses
    act! { put :update, :id => 1, :status => @attributes, :format => 'xml' }

    before do
      @status.stub!(:save).and_return(true)
    end
    
    it.assigns :status
    it.renders :blank
  end
  
  describe StatusesController, "(unsuccessful save, xml)" do
    define_models :statuses
    act! { put :update, :id => 1, :status => @attributes, :format => 'xml' }

    before do
      @status.stub!(:save).and_return(false)
    end
    
    it.assigns :status
    it.renders :xml, "status.errors", :status => :unprocessable_entity
  end
end

describe StatusesController, "DELETE #destroy" do
  define_models :statuses
  act! { delete :destroy, :id => 1 }
  
  before do
    @status = statuses(:default)
    @status.stub!(:destroy)
    Status.stub!(:find).with('1').and_return(@status)
  end

  it.assigns :status
  it.redirects_to { statuses_path }
  
  describe StatusesController, "(xml)" do
    define_models :statuses
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it.assigns :status
    it.renders :blank
  end
end