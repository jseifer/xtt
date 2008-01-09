require File.dirname(__FILE__) + '/../spec_helper'

describe GroupStatusesController, "GET #index" do
  define_models :users

  act! { get :index, :group_id => 1 }

  before do
    @statuses = []
    @group = groups :default
    @group.stub!(:statuses).and_return(@statuses)
    Group.stub!(:find).with('1').and_return(@group)
    controller.stub!(:login_required)
  end
  
  it_assigns :statuses, :group
  it_renders :template, :index

  describe GroupStatusesController, "(xml)" do
    define_models :users
    
    act! { get :index, :group_id => 1, :format => 'xml' }

    it_assigns :statuses, :group
    it_renders :xml, :statuses
  end
end

describe GroupStatusesController, "GET #show" do
  before do
    controller.stub!(:login_required)
  end

  act! { get :show, :group_id => 1, :id => 1 }
  it_redirects_to { status_path(1) }
end

describe GroupStatusesController, "GET #new" do
  before do
    controller.stub!(:login_required)
  end

  act! { get :new, :group_id => 1 }
  it_redirects_to { new_status_path }
end

describe GroupStatusesController, "GET #edit" do
  before do
    controller.stub!(:login_required)
  end

  act! { get :edit, :group_id => 1, :id => 1 }
  it_redirects_to { edit_status_path(1) }
end


describe GroupStatusesController, "POST #create" do
  before do
    controller.stub!(:login_required)
  end

  act! { post :create, :group_id => 1 }
  it_redirects_to { new_status_path }
end

describe GroupStatusesController, "PUT #update" do
  before do
    controller.stub!(:login_required)
  end

  act! { put :update, :group_id => 1, :id => 1 }
  it_redirects_to { edit_status_path(1) }
end

describe GroupStatusesController, "DELETE #destroy" do
  before do
    controller.stub!(:login_required)
  end

  act! { delete :destroy, :group_id => 1, :id => 1 }
  it_redirects_to { edit_status_path(1) }
end