require File.dirname(__FILE__) + '/../spec_helper'

describe GroupProjectsController, "GET #index" do
  define_models :users

  act! { get :index, :group_id => 1 }

  before do
    @projects = []
    @group = groups :default
    @group.stub!(:projects).and_return(@projects)
    Group.stub!(:find).with('1').and_return(@group)
    controller.stub!(:login_required)
  end
  
  it_assigns :projects, :group
  it_renders :template, :index

  describe GroupProjectsController, "(xml)" do
    define_models :users
    
    act! { get :index, :group_id => 1, :format => 'xml' }

    it_assigns :projects, :group
    it_renders :xml, :projects
  end
end

describe GroupProjectsController, "GET #show" do
  before do
    controller.stub!(:login_required)
  end

  act! { get :show, :group_id => 1, :id => 1 }
  it_redirects_to { project_path(1) }
end

describe GroupProjectsController, "GET #new" do
  define_models :users
  act! { get :new, :group_id => 1 }
  before do
    @project  = Project.new
    controller.stub!(:login_required)
    Group.stub!(:find).with('1').and_return(mock_model(Group))
  end

  it "assigns @project" do
    act!
    assigns[:project].should be_new_record
  end
  
  it_renders :template, :new
  
  describe GroupProjectsController, "(xml)" do
    define_models :users
    act! { get :new, :group_id => 1, :format => 'xml' }

    it_renders :xml, :project
  end
end

describe GroupProjectsController, "GET #edit" do
  before do
    controller.stub!(:login_required)
  end

  act! { get :edit, :group_id => 1, :id => 1 }
  it_redirects_to { edit_project_path(1) }
end


describe GroupProjectsController, "POST #create" do
  before do
    @attributes = {}
    @project = mock_model Project, :new_record? => false, :errors => []
    @group = groups(:default)
    @group.projects.stub!(:build).with(@attributes).and_return(@project)
    Group.stub!(:find).with('1').and_return(@group)
    controller.stub!(:login_required)
  end
  
  describe GroupProjectsController, "(successful creation)" do
    define_models :users
    act! { post :create, :group_id => 1, :project => @attributes }

    before do
      @project.stub!(:save).and_return(true)
      controller.stub!(:login_required)
    end
    
    it_assigns :project, :flash => { :notice => :not_nil }
    it_redirects_to { project_path(@project) }
  end

  describe GroupProjectsController, "(unsuccessful creation)" do
    define_models :users
    act! { post :create, :group_id => 1, :project => @attributes }

    before do
      @project.stub!(:save).and_return(false)
      controller.stub!(:login_required)
    end
    
    it_assigns :project
    it_renders :template, :new
  end
  
  describe GroupProjectsController, "(successful creation, xml)" do
    define_models :users
    act! { post :create, :group_id => 1, :project => @attributes, :format => 'xml' }

    before do
      @project.stub!(:save).and_return(true)
      @project.stub!(:to_xml).and_return("mocked content")
      controller.stub!(:login_required)
    end
    
    it_assigns :project, :headers => { :Location => lambda { project_url(@project) } }
    it_renders :xml, :project, :status => :created
  end
  
  describe GroupProjectsController, "(unsuccessful creation, xml)" do
    define_models :users
    act! { post :create, :group_id => 1, :project => @attributes, :format => 'xml' }

    before do
      @project.stub!(:save).and_return(false)
      controller.stub!(:login_required)
    end
    
    it_assigns :project
    it_renders :xml, "project.errors", :status => :unprocessable_entity
  end
end

describe GroupProjectsController, "PUT #update" do
  before do
    controller.stub!(:login_required)
  end

  act! { put :update, :group_id => 1, :id => 1 }
  it_redirects_to { edit_project_path(1) }
end

describe GroupProjectsController, "DELETE #destroy" do
  before do
    controller.stub!(:login_required)
  end

  act! { delete :destroy, :group_id => 1, :id => 1 }
  it_redirects_to { edit_project_path(1) }
end