require File.dirname(__FILE__) + '/../spec_helper'



describe TendrilsController, "GET #index" do
  define_models

  act! { get :index }

  before do
    @tendril = []
    login_as :default

    @user.campfires.stub!(:find).with(:all).and_return(@tendril)
  end

  it_assigns :tendril
  it_renders :template, :index

  describe TendrilsController, "(xml)" do
    define_models

    act! { get :index, :format => 'xml' }

    it_assigns :tendril
    it_renders :xml, :tendril
  end

  describe TendrilsController, "(json)" do
    define_models

    act! { get :index, :format => 'json' }

    it_assigns :tendril
    it_renders :json, :tendril
  end


end

describe TendrilsController, "GET #show" do
  define_models

  act! { get :show, :id => 1 }

  before do
    @tendril  = campfires(:default)
    login_as :default
    @user.campfires.stub!(:find).with('1').and_return(@tendril)
  end

  it_assigns :tendril
  it_renders :template, :show

  describe TendrilsController, "(xml)" do
    define_models

    act! { get :show, :id => 1, :format => 'xml' }

    it_renders :xml, :tendril
  end

  describe TendrilsController, "(json)" do
    define_models

    act! { get :show, :id => 1, :format => 'json' }

    it_renders :json, :tendril
  end


end

describe TendrilsController, "GET #new" do
  define_models
  act! { get :new }
  before do
    login_as :default
    @tendril  = @user.campfires.new
  end

  it "assigns @tendril" do
    act!
    assigns[:tendril].should be_new_record
  end

  it_renders :template, :new

  describe TendrilsController, "(xml)" do
    define_models
    act! { get :new, :format => 'xml' }

    it_renders :xml, :tendril
  end

  describe TendrilsController, "(json)" do
    define_models
    act! { get :new, :format => 'json' }

    it_renders :json, :tendril
  end


end

describe TendrilsController, "POST #create" do
  before do
    @attributes = {}
    @tendril = mock_model Campfire, :new_record? => false, :errors => []
    login_as :default
    @user.campfires.stub!(:new).with(@attributes).and_return(@tendril)
  end

  describe TendrilsController, "(successful creation)" do
    define_models
    act! { post :create, :tendril => @attributes }

    before do
      @tendril.stub!(:save).and_return(true)
    end

    it_assigns :tendril, :flash => { :notice => :not_nil }
    it_redirects_to { notify_path(@tendril) }
  end

  describe TendrilsController, "(unsuccessful creation)" do
    define_models
    act! { post :create, :tendril => @attributes }

    before do
      @tendril.stub!(:save).and_return(false)
    end

    it_assigns :tendril
    it_renders :template, :new
  end

  describe TendrilsController, "(successful creation, xml)" do
    define_models
    act! { post :create, :tendril => @attributes, :format => 'xml' }

    before do
      @tendril.stub!(:save).and_return(true)
      @tendril.stub!(:to_xml).and_return("mocked content")
    end

    it_assigns :tendril, :headers => { :Location => lambda { notify_url(@tendril) } }
    it_renders :xml, :tendril, :status => :created
  end

  describe TendrilsController, "(unsuccessful creation, xml)" do
    define_models
    act! { post :create, :tendril => @attributes, :format => 'xml' }

    before do
      @tendril.stub!(:save).and_return(false)
    end

    it_assigns :tendril
    it_renders :xml, "tendril.errors", :status => :unprocessable_entity
  end

  describe TendrilsController, "(successful creation, json)" do
    define_models
    act! { post :create, :tendril => @attributes, :format => 'json' }

    before do
      @tendril.stub!(:save).and_return(true)
      @tendril.stub!(:to_json).and_return("mocked content")
    end

    it_assigns :tendril, :headers => { :Location => lambda { notify_url(@tendril) } }
    it_renders :json, :tendril, :status => :created
  end

  describe TendrilsController, "(unsuccessful creation, json)" do
    define_models
    act! { post :create, :tendril => @attributes, :format => 'json' }

    before do
      @tendril.stub!(:save).and_return(false)
    end

    it_assigns :tendril
    it_renders :json, "tendril.errors", :status => :unprocessable_entity
  end

end

describe TendrilsController, "GET #edit" do
  define_models
  act! { get :edit, :id => 1 }

  before do
    @tendril  = campfires(:default)
    login_as :default
    @user.campfires.stub!(:find).with('1').and_return(@tendril)
  end

  it_assigns :tendril
  it_renders :template, :edit
end

describe TendrilsController, "PUT #update" do
  before do
    @attributes = {}
    @tendril = campfires(:default)
    login_as :default
    @user.campfires.stub!(:find).with('1').and_return(@tendril)
  end

  describe TendrilsController, "(successful save)" do
    define_models
    act! { put :update, :id => 1, :tendril => @attributes }

    before do
      @tendril.stub!(:save).and_return(true)
    end

    it_assigns :tendril, :flash => { :notice => :not_nil }
    it_redirects_to { notify_path(@tendril) }
  end

  describe TendrilsController, "(unsuccessful save)" do
    define_models
    act! { put :update, :id => 1, :tendril => @attributes }

    before do
      @tendril.stub!(:save).and_return(false)
    end

    it_assigns :tendril
    it_renders :template, :edit
  end

  describe TendrilsController, "(successful save, xml)" do
    define_models
    act! { put :update, :id => 1, :tendril => @attributes, :format => 'xml' }

    before do
      @tendril.stub!(:save).and_return(true)
    end

    it_assigns :tendril
    it_renders :blank
  end

  describe TendrilsController, "(unsuccessful save, xml)" do
    define_models
    act! { put :update, :id => 1, :tendril => @attributes, :format => 'xml' }

    before do
      @tendril.stub!(:save).and_return(false)
    end

    it_assigns :tendril
    it_renders :xml, "tendril.errors", :status => :unprocessable_entity
  end

  describe TendrilsController, "(successful save, json)" do
    define_models
    act! { put :update, :id => 1, :tendril => @attributes, :format => 'json' }

    before do
      @tendril.stub!(:save).and_return(true)
    end

    it_assigns :tendril
    it_renders :blank
  end

  describe TendrilsController, "(unsuccessful save, json)" do
    define_models
    act! { put :update, :id => 1, :tendril => @attributes, :format => 'json' }

    before do
      @tendril.stub!(:save).and_return(false)
    end

    it_assigns :tendril
    it_renders :json, "tendril.errors", :status => :unprocessable_entity
  end

end

describe TendrilsController, "DELETE #destroy" do
  define_models
  act! { delete :destroy, :id => 1 }

  before do
    @tendril = campfires(:default)
    @tendril.stub!(:destroy)
    login_as :default
    @user.campfires.stub!(:find).with('1').and_return(@tendril)
  end

  it_assigns :tendril
  it_redirects_to { tendril_url }

  describe TendrilsController, "(xml)" do
    define_models
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it_assigns :tendril
    it_renders :blank
  end

  describe TendrilsController, "(json)" do
    define_models
    act! { delete :destroy, :id => 1, :format => 'json' }

    it_assigns :tendril
    it_renders :blank
  end


end