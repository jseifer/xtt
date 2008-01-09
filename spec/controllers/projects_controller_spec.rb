require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectsController, "GET #index" do
  define_models

  act! { get :index }

  before do
    @projects = []
    @user = mock("User")
    @user.stub!(:projects).and_return(@projects)
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
  
  describe ProjectsController, "(/users/1/projects)" do
    act! { get :index, :user_id => 1 }
    it_assigns :projects => nil
    it_redirects_to { projects_path }
  end
  
  describe ProjectsController, "(/groups/1/projects)" do
    define_models :users
    act! { get :index, :group_id => 1 }
    it_assigns :projects, :group
    it_renders :template, :index

    before do
      @projects = []
      @user  = users(:default)
      @group = groups(:default)
      Group.stub!(:find).with('1').and_return(@group)
      @group.stub!(:projects).and_return(@projects)
      controller.stub!(:current_user).and_return(@user)
      controller.stub!(:login_required)
    end
    
    #it "doesn't provide access to other groups" do
    #  @user = users(:pending)
    #  controller.stub!(:logged_in?).and_return(false)
    #  acting.should redirect_to projects_path
    #end
  end
end

describe ProjectsController, "GET #show" do
  define_models

  act! { get :show, :id => 1 }

  before do
    @project = projects(:default)
    Project.stub!(:find).with('1').and_return(@project)
    controller.stub!(:group).and_return(@group)
    controller.stub!(:login_required)
  end
  
  it_assigns :project
  it_renders :template, :show
  
  describe ProjectsController, "(xml)" do
    define_models
    
    act! { get :show, :id => 1, :format => 'xml' }

    it_renders :xml, :project
  end

  #describe ProjectsController, "(/users/1/projects/1)" do
  #  define_models
  #  act! { get :show, :user_id => 1, :id => 1 }
  #  it_assigns :project => nil
  #  it_redirects_to { project_path(1) }
  #end
  #
  #describe ProjectsController, "(/groups/1/projects/1)" do
  #  define_models
  #  act! { get :show, :group_id => 1, :id => 1 }
  #  it_assigns :project => nil
  #  it_redirects_to { project_path(1) }
  #end
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
  before do
    @attributes = {}
    @project = mock_model Project, :new_record? => false, :errors => []
    @group = groups(:default)
    @group.stub!(:projects).and_return([])
    Group.stub!(:find).with('2').and_return(@group)
    @group.projects.stub!(:build).with(@attributes).and_return(@project)
    controller.stub!(:login_required)
  end
  
  describe ProjectsController, "(successful creation)" do
    define_models
    act! { post :create, :group_id => 2, :project => @attributes }

    before do
      @project.stub!(:save).and_return(true)
      controller.stub!(:login_required)
    end
    
    it_assigns :project, :flash => { :notice => :not_nil }
    it_redirects_to { project_path(@project) }
  end

  describe ProjectsController, "(unsuccessful creation)" do
    define_models
    act! { post :create, :group_id => 2, :project => @attributes }

    before do
      @project.stub!(:save).and_return(false)
      controller.stub!(:login_required)
    end
    
    it_assigns :project
    it_renders :template, :new
  end
  
  describe ProjectsController, "(successful creation, xml)" do
    define_models
    act! { post :create, :group_id => 2, :project => @attributes, :format => 'xml' }

    before do
      @project.stub!(:save).and_return(true)
      @project.stub!(:to_xml).and_return("mocked content")
      controller.stub!(:login_required)
    end
    
    it_assigns :project, :headers => { :Location => lambda { project_url(@project) } }
    it_renders :xml, :project, :status => :created
  end
  
  describe ProjectsController, "(unsuccessful creation, xml)" do
    define_models
    act! { post :create, :group_id => 2, :project => @attributes, :format => 'xml' }

    before do
      @project.stub!(:save).and_return(false)
      controller.stub!(:login_required)
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
    controller.stub!(:group).and_return(@group)
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