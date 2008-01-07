require File.dirname(__FILE__) + '/../spec_helper'

describe AccountsController, "GET #index" do
  define_models

  act! { get :index }

  before do
    @accounts = []
    Account.stub!(:find).with(:all).and_return(@accounts)
    controller.stub!(:admin_required)
  end
  
  it.assigns :accounts
  it.renders :template, :index
end

describe AccountsController, "GET #show" do
  define_models

  act! { get :show, :id => 1 }

  before do
    @account  = accounts(:default)
    Account.stub!(:find).with('1').and_return(@account)
    controller.stub!(:admin_required)
  end
  
  it.assigns :account
  it.renders :template, :show
end

describe AccountsController, "GET #new" do
  define_models
  act! { get :new }
  before do
    @account  = Account.new
    controller.stub!(:admin_required)
  end

  it "assigns @account" do
    act!
    assigns[:account].should be_new_record
  end
  
  it.renders :template, :new
end

describe AccountsController, "GET #edit" do
  define_models
  act! { get :edit, :id => 1 }
  
  before do
    @account  = accounts(:default)
    Account.stub!(:find).with('1').and_return(@account)
    controller.stub!(:admin_required)
  end

  it.assigns :account
  it.renders :template, :edit
end

describe AccountsController, "POST #create" do
  before do
    @attributes = {}
    @account = mock_model Account, :new_record? => false, :errors => []
    Account.stub!(:new).with(@attributes).and_return(@account)
    controller.stub!(:admin_required)
  end
  
  describe AccountsController, "(successful creation)" do
    define_models
    act! { post :create, :account => @attributes }

    before do
      @account.stub!(:save).and_return(true)
      controller.stub!(:admin_required)
    end
    
    it.assigns :account, :flash => { :notice => :not_nil }
    it.redirects_to { account_path(@account) }
  end

  describe AccountsController, "(unsuccessful creation)" do
    define_models
    act! { post :create, :account => @attributes }

    before do
      @account.stub!(:save).and_return(false)
      controller.stub!(:admin_required)
    end
    
    it.assigns :account
    it.renders :template, :new
  end
end

describe AccountsController, "PUT #update" do
  before do
    @attributes = {}
    @account = accounts(:default)
    Account.stub!(:find).with('1').and_return(@account)
    controller.stub!(:admin_required)
  end
  
  describe AccountsController, "(successful save)" do
    define_models
    act! { put :update, :id => 1, :account => @attributes }

    before do
      @account.stub!(:save).and_return(true)
      controller.stub!(:admin_required)
    end
    
    it.assigns :account, :flash => { :notice => :not_nil }
    it.redirects_to { account_path(@account) }
  end

  describe AccountsController, "(unsuccessful save)" do
    define_models
    act! { put :update, :id => 1, :account => @attributes }

    before do
      @account.stub!(:save).and_return(false)
      controller.stub!(:admin_required)
    end
    
    it.assigns :account
    it.renders :template, :edit
  end
end

describe AccountsController, "DELETE #destroy" do
  define_models
  act! { delete :destroy, :id => 1 }
  
  before do
    @account = accounts(:default)
    @account.stub!(:destroy)
    Account.stub!(:find).with('1').and_return(@account)
    controller.stub!(:admin_required)
  end

  it.assigns :account
  it.redirects_to { accounts_path }
end