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
    pending "on hold, need to use invitations instead"
    lambda do
      create_user(:login => nil)
      assigns[:user].errors.on(:login).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password on signup' do
    pending "on hold, need to use invitations instead"
    lambda do
      create_user(:password => nil)
      assigns[:user].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password confirmation on signup' do
    pending "on hold, need to use invitations instead"
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    pending "on hold, need to use invitations instead"
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
    pending "Email functionality has not been written"
    lambda{ create_user }.should change(ActionMailer::Base.deliveries, :size).by(1)
  end
  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire', :password_confirmation => 'quire' }.merge(options)
  end
end