require File.dirname(__FILE__) + '/../spec_helper'

describe ContextsController, "GET #index" do
  # fixture definition

  act! { get :index }

  before do
    @contexts = []
    Context.stub!(:find).with(:all).and_return(@contexts)
  end
  
  it_assigns :contexts
  it_renders :template, :index

  describe ContextsController, "(xml)" do
    # fixture definition
    
    act! { get :index, :format => 'xml' }

    it_assigns :contexts
    it_renders :xml, :contexts
  end

  describe ContextsController, "(json)" do
    # fixture definition
    
    act! { get :index, :format => 'json' }

    it_assigns :contexts
    it_renders :json, :contexts
  end


end

describe ContextsController, "GET #show" do
  # fixture definition

  act! { get :show, :id => 1 }

  before do
    @context  = contexts(:default)
    Context.stub!(:find).with('1').and_return(@context)
  end
  
  it_assigns :context
  it_renders :template, :show
  
  describe ContextsController, "(xml)" do
    # fixture definition
    
    act! { get :show, :id => 1, :format => 'xml' }

    it_renders :xml, :context
  end

  describe ContextsController, "(json)" do
    # fixture definition
    
    act! { get :show, :id => 1, :format => 'json' }

    it_renders :json, :context
  end


end

describe ContextsController, "GET #new" do
  # fixture definition
  act! { get :new }
  before do
    @context  = Context.new
  end

  it "assigns @context" do
    act!
    assigns[:context].should be_new_record
  end
  
  it_renders :template, :new
  
  describe ContextsController, "(xml)" do
    # fixture definition
    act! { get :new, :format => 'xml' }

    it_renders :xml, :context
  end

  describe ContextsController, "(json)" do
    # fixture definition
    act! { get :new, :format => 'json' }

    it_renders :json, :context
  end


end

describe ContextsController, "POST #create" do
  before do
    @attributes = {}
    @context = mock_model Context, :new_record? => false, :errors => []
    Context.stub!(:new).with(@attributes).and_return(@context)
  end
  
  describe ContextsController, "(successful creation)" do
    # fixture definition
    act! { post :create, :context => @attributes }

    before do
      @context.stub!(:save).and_return(true)
    end
    
    it_assigns :context, :flash => { :notice => :not_nil }
    it_redirects_to { context_path(@context) }
  end

  describe ContextsController, "(unsuccessful creation)" do
    # fixture definition
    act! { post :create, :context => @attributes }

    before do
      @context.stub!(:save).and_return(false)
    end
    
    it_assigns :context
    it_renders :template, :new
  end
  
  describe ContextsController, "(successful creation, xml)" do
    # fixture definition
    act! { post :create, :context => @attributes, :format => 'xml' }

    before do
      @context.stub!(:save).and_return(true)
      @context.stub!(:to_xml).and_return("mocked content")
    end
    
    it_assigns :context, :headers => { :Location => lambda { context_url(@context) } }
    it_renders :xml, :context, :status => :created
  end
  
  describe ContextsController, "(unsuccessful creation, xml)" do
    # fixture definition
    act! { post :create, :context => @attributes, :format => 'xml' }

    before do
      @context.stub!(:save).and_return(false)
    end
    
    it_assigns :context
    it_renders :xml, "context.errors", :status => :unprocessable_entity
  end

  describe ContextsController, "(successful creation, json)" do
    # fixture definition
    act! { post :create, :context => @attributes, :format => 'json' }

    before do
      @context.stub!(:save).and_return(true)
      @context.stub!(:to_json).and_return("mocked content")
    end
    
    it_assigns :context, :headers => { :Location => lambda { context_url(@context) } }
    it_renders :json, :context, :status => :created
  end
  
  describe ContextsController, "(unsuccessful creation, json)" do
    # fixture definition
    act! { post :create, :context => @attributes, :format => 'json' }

    before do
      @context.stub!(:save).and_return(false)
    end
    
    it_assigns :context
    it_renders :json, "context.errors", :status => :unprocessable_entity
  end

end

describe ContextsController, "GET #edit" do
  # fixture definition
  act! { get :edit, :id => 1 }
  
  before do
    @context  = contexts(:default)
    Context.stub!(:find).with('1').and_return(@context)
  end

  it_assigns :context
  it_renders :template, :edit
end

describe ContextsController, "PUT #update" do
  before do
    @attributes = {}
    @context = contexts(:default)
    Context.stub!(:find).with('1').and_return(@context)
  end
  
  describe ContextsController, "(successful save)" do
    # fixture definition
    act! { put :update, :id => 1, :context => @attributes }

    before do
      @context.stub!(:save).and_return(true)
    end
    
    it_assigns :context, :flash => { :notice => :not_nil }
    it_redirects_to { context_path(@context) }
  end

  describe ContextsController, "(unsuccessful save)" do
    # fixture definition
    act! { put :update, :id => 1, :context => @attributes }

    before do
      @context.stub!(:save).and_return(false)
    end
    
    it_assigns :context
    it_renders :template, :edit
  end
  
  describe ContextsController, "(successful save, xml)" do
    # fixture definition
    act! { put :update, :id => 1, :context => @attributes, :format => 'xml' }

    before do
      @context.stub!(:save).and_return(true)
    end
    
    it_assigns :context
    it_renders :blank
  end
  
  describe ContextsController, "(unsuccessful save, xml)" do
    # fixture definition
    act! { put :update, :id => 1, :context => @attributes, :format => 'xml' }

    before do
      @context.stub!(:save).and_return(false)
    end
    
    it_assigns :context
    it_renders :xml, "context.errors", :status => :unprocessable_entity
  end

  describe ContextsController, "(successful save, json)" do
    # fixture definition
    act! { put :update, :id => 1, :context => @attributes, :format => 'json' }

    before do
      @context.stub!(:save).and_return(true)
    end
    
    it_assigns :context
    it_renders :blank
  end
  
  describe ContextsController, "(unsuccessful save, json)" do
    # fixture definition
    act! { put :update, :id => 1, :context => @attributes, :format => 'json' }

    before do
      @context.stub!(:save).and_return(false)
    end
    
    it_assigns :context
    it_renders :json, "context.errors", :status => :unprocessable_entity
  end

end

describe ContextsController, "DELETE #destroy" do
  # fixture definition
  act! { delete :destroy, :id => 1 }
  
  before do
    @context = contexts(:default)
    @context.stub!(:destroy)
    Context.stub!(:find).with('1').and_return(@context)
  end

  it_assigns :context
  it_redirects_to { contexts_path }
  
  describe ContextsController, "(xml)" do
    # fixture definition
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it_assigns :context
    it_renders :blank
  end

  describe ContextsController, "(json)" do
    # fixture definition
    act! { delete :destroy, :id => 1, :format => 'json' }

    it_assigns :context
    it_renders :blank
  end


end