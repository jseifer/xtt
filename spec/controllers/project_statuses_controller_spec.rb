require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectStatusesController, "GET #index" do
  define_models :users

  act! { get :index, :project_id => 1 }

  before do
    @statuses = []
    @project = projects :default
    @project.stub!(:statuses).and_return(@statuses)
    Project.stub!(:find).with('1').and_return(@project)
    controller.stub!(:login_required)
  end
  
  it_assigns :statuses, :project
  it_renders :template, :index

  describe ProjectStatusesController, "(xml)" do
    define_models :users
    
    act! { get :index, :project_id => 1, :format => 'xml' }

    it_assigns :statuses, :project
    it_renders :xml, :statuses
  end
end

describe ProjectStatusesController, "GET #show" do
  before do
    controller.stub!(:login_required)
  end

  act! { get :show, :project_id => 1, :id => 1 }
  it_redirects_to { status_path(1) }
end

describe ProjectStatusesController, "GET #new" do
  before do
    controller.stub!(:login_required)
  end

  act! { get :new, :project_id => 1 }
  it_redirects_to { new_status_path }
end

describe ProjectStatusesController, "GET #edit" do
  before do
    controller.stub!(:login_required)
  end

  act! { get :edit, :project_id => 1, :id => 1 }
  it_redirects_to { edit_status_path(1) }
end


describe ProjectStatusesController, "POST #create" do
  before do
    controller.stub!(:login_required)
  end

  act! { post :create, :project_id => 1 }
  it_redirects_to { new_status_path }
end

describe ProjectStatusesController, "PUT #update" do
  before do
    controller.stub!(:login_required)
  end

  act! { put :update, :project_id => 1, :id => 1 }
  it_redirects_to { edit_status_path(1) }
end

describe ProjectStatusesController, "DELETE #destroy" do
  before do
    controller.stub!(:login_required)
  end

  act! { delete :destroy, :project_id => 1, :id => 1 }
  it_redirects_to { edit_status_path(1) }
end