require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectsController, "GET #index" do
  define_models

  act! { get :index }

  before do
    @projects = []
    @user = mock_model User, :projects => @projects, :active? => true, :time_zone => "UTC"
    controller.stub!(:current_user).and_return(@user)
    controller.stub!(:login_required)
  end
  
  it_assigns :projects
  it_renders :template, :index

  describe ProjectsController, "(xml)" do
    define_models
    
    act! { get :index, :format => 'xml' }

    it_assigns :projects
    it_renders :xml, :projects
  end
end

describe ProjectsController, "GET #show" do
    
  before do
    @project = projects(:default)
    @statuses = []
    Project.stub!(:find).with('1').and_return(@project)
    @project.stub!(:statuses).and_return([])
    controller.stub!(:login_required)
    controller.stub!(:current_user).and_return(mock_model(User, :id => 55, :active? => true, :time_zone => "UTC"))
  end

  [ {:user_id => nil,   :filter => nil, :args => [nil, nil]},
    {:user_id => 'all', :filter => nil, :args => [nil, nil]},
    {:user_id => 'me',  :filter => nil, :args => [55,  nil]},
    {:user_id => '5',   :filter => nil, :args => [5,   nil]},
    {:user_id => nil,   :filter => 'weekly', :args => [nil, 'weekly']},
    {:user_id => 'all', :filter => 'weekly', :args => [nil, 'weekly']},
    {:user_id => 'me',  :filter => 'weekly', :args => [55,  'weekly']},
    {:user_id => '5',   :filter => 'weekly', :args => [5,   'weekly']} ].each do |options|
      
    describe ProjectsController, "(xml)" do
      define_models
      
      act! { get :show, options.merge(:id => 1) }
      
      before do
        @project.statuses.stub!(:filter).with(*options[:args]).and_return(@statuses)
      end
      
      it_assigns :project, :statuses
      it_renders :template, :show

      describe ProjectsController, "(xml)" do
        define_models
        
        act! { get :show, options.merge(:id => 1, :format => 'xml') }
      
        it_renders :xml, :project
      end if options[:user_id].nil? && options[:filter].nil?
    end
  end
end

describe ProjectsController, "GET #new" do
  define_models
  act! { get :new }
  before do
    @project  = Project.new
    controller.stub!(:login_required)
  end

  it "assigns @project" do
    act!
    assigns[:project].should be_new_record
  end
  
  it_renders :template, :new
  
  describe ProjectsController, "(xml)" do
    define_models
    act! { get :new, :format => 'xml' }

    it_renders :xml, :project
  end
end

describe ProjectsController, "GET #edit" do
  define_models
  act! { get :edit, :id => 1 }
  
  before do
    @project = projects(:default)
    Project.stub!(:find).with('1').and_return(@project)
    controller.stub!(:login_required)
  end

  it_assigns :project
  it_renders :template, :edit
end

describe ProjectsController, "POST #create" do
  define_models :users
  before do
    login_as :default
    @attributes = {}
    @project = mock_model Project, :new_record? => false, :errors => []
    @user = mock_model User, :owned_projects => [], :active? => true, :time_zone => "UTC"
    @user.owned_projects.stub!(:build).with(@attributes).and_return(@project)
    controller.stub!(:current_user).and_return(@user)
    controller.stub!(:login_required)
  end
  
  describe ProjectsController, "(successful creation)" do
    define_models
    act! { post :create, :project => @attributes }

    before do
      @project.stub!(:save).and_return(true)
    end
    
    it_assigns :project, :flash => { :notice => :not_nil }
    it_redirects_to { project_path(@project) }
  end

  describe ProjectsController, "(unsuccessful creation)" do
    define_models
    act! { post :create, :project => @attributes }

    before do
      @project.stub!(:save).and_return(false)
    end
    
    it_assigns :project
    it_renders :template, :new
  end
  
  describe ProjectsController, "(successful creation, owned by current_user)" do
    define_models
    act! { post :create, :project => @attributes }

    before do
      @user.owned_projects.stub!(:build).with(@attributes).and_return(@project)
      @project.stub!(:save).and_return(true)
    end
    
    it_assigns :project, :flash => { :notice => :not_nil }
    it_redirects_to { project_path(@project) }
  end
  
  describe ProjectsController, "(successful creation, xml)" do
    define_models :users
    act! { post :create, :project => @attributes, :format => 'xml' }

    before do
      @project.stub!(:save).and_return(true)
      @project.stub!(:to_xml).and_return("mocked content")
    end
    
    it_assigns :project, :headers => { :Location => lambda { project_url(@project) } }
    it_renders :xml, :project, :status => :created
  end
  
  describe ProjectsController, "(unsuccessful creation, xml)" do
    define_models
    act! { post :create, :project => @attributes, :format => 'xml' }

    before do
      @project.stub!(:save).and_return(false)
    end
    
    it_assigns :project
    it_renders :xml, "project.errors", :status => :unprocessable_entity
  end
end

describe ProjectsController, "PUT #update" do
  before do
    @attributes = {}
    @project = projects(:default)
    Project.stub!(:find).with('1').and_return(@project)
    controller.stub!(:login_required)
  end
  
  describe ProjectsController, "(successful save)" do
    define_models
    act! { put :update, :id => 1, :project => @attributes }

    before do
      @project.stub!(:save).and_return(true)
      controller.stub!(:login_required)
    end
    
    it_assigns :project, :flash => { :notice => :not_nil }
    it_redirects_to { project_path(@project) }
  end

  describe ProjectsController, "(unsuccessful save)" do
    define_models
    act! { put :update, :id => 1, :project => @attributes }

    before do
      @project.stub!(:save).and_return(false)
      controller.stub!(:login_required)
    end
    
    it_assigns :project
    it_renders :template, :edit
  end
  
  describe ProjectsController, "(successful save, xml)" do
    define_models
    act! { put :update, :id => 1, :project => @attributes, :format => 'xml' }

    before do
      @project.stub!(:save).and_return(true)
      controller.stub!(:login_required)
    end
    
    it_assigns :project
    it_renders :blank
  end
  
  describe ProjectsController, "(unsuccessful save, xml)" do
    define_models
    act! { put :update, :id => 1, :project => @attributes, :format => 'xml' }

    before do
      @project.stub!(:save).and_return(false)
      controller.stub!(:login_required)
    end
    
    it_assigns :project
    it_renders :xml, "project.errors", :status => :unprocessable_entity
  end
end

describe ProjectsController, "DELETE #destroy" do
  define_models
  act! { delete :destroy, :id => 1 }
  
  before do
    @project = projects(:default)
    @project.stub!(:destroy)
    Project.stub!(:find).with('1').and_return(@project)
    controller.stub!(:login_required)
  end

  it_assigns :project
  it_redirects_to { projects_path }
  
  describe ProjectsController, "(xml)" do
    define_models
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it_assigns :project
    it_renders :blank
  end
end