require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  define_models :users

  it 'allows signup' do
    lambda do
      create_user
      response.should be_redirect      
    end.should change(User, :count).by(1)
  end

  it 'signs up user in pending state' do
    create_user
    assigns(:user).reload.should be_pending
  end

  it 'signs up user with activation code' do
    create_user
    assigns(:user).reload.activation_code.should_not be_nil
  end

  it 'requires login on signup' do
    lambda do
      create_user(:login => nil)
      assigns[:user].errors.on(:login).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password on signup' do
    lambda do
      create_user(:password => nil)
      assigns[:user].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_user(:email => nil)
      assigns[:user].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'activates user' do
    User.authenticate(users(:pending).login, 'test').should be_nil
    get :activate, :activation_code => users(:pending).activation_code
    response.should redirect_to('/')
    User.authenticate(users(:pending).login, 'test').should == users(:pending)
  end
  
  it 'does not activate user without key' do
    get :activate
    flash[:notice].should be_nil
  end
  
  it 'does not activate user with blank key' do
    get :activate, :activation_code => ''
    flash[:notice].should be_nil
  end
  
  it "sends an email to the user on create" do
    lambda{ create_user }.should change(ActionMailer::Base.deliveries, :size).by(1)
  end
  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire', :password_confirmation => 'quire' }.merge(options)
  end
end

describe UsersController, "GET #invite" do
  define_models
  act! { get :invite, :code => invitations(:default).code }
  before do
    @invitation = invitations(:default)
  end

  it_assigns :invitation

  it "assigns @user and email" do
    act!
    assigns[:user].should be_new_record
    assigns[:user].email.should == @invitation.email
  end
  
  it_renders :template, :new
end

describe UsersController, "POST #create (with invitation)" do
  before do
    @attributes = { :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.stringify_keys
    @invitation = invitations(:default)
    @project    = projects(:default)
    @user       = User.new @attributes
    User.stub!(:new).with(@attributes).and_return(@user)
  end

  describe UsersController, "(successful creation)" do
    define_models
    act! { post :create, :user => @attributes, :code => @invitation.code }
    
    before do
      Invitation.update_all ['project_ids = ?', @project.id.to_s]
    end
    
    it_assigns :user, :invitation
    it_redirects_to { login_path }
    
    it "invites user to project" do
      act!
      @user.can_access?(@project).should == true
    end
    
    it "deletes invitation" do
      act!
      lambda { @invitation.reload }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe UsersController, "(unsuccessful creation)" do
    define_models
    act! { post :create, :user => @attributes, :code => @invitation.code }
  
    before do
      @user.errors.stub!(:empty?).and_return(false)
    end
    
    it_assigns :user, :invitation
    it_renders :template, :new
    
    it "spares invitation" do
      act!
      lambda { @invitation.reload }.should_not raise_error(ActiveRecord::RecordNotFound)
    end
  end
end