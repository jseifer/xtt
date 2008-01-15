require File.dirname(__FILE__) + '/../spec_helper'

describe_validations_for User, 
  :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' do
    presence_of :login, :password, :password_confirmation, :email
end

describe User do
  define_models :users

  describe "being bootstrapped" do
    define_models :copy => false do
      model User
    end
  
    it "creates initial user as admin" do
      create_user.should be_admin
    end
  end
  
  describe "cached status associations" do
    define_models

    before do
      @user    = users(:default)
      @status  = statuses(:default)
      @project = projects(:default)
    end
    
    it "stores last status" do
      @user.last_status_id = @status.id
      @user.last_status.should == @status
    end
    
    it "stores last status project" do
      @user.last_status_project_id = @project.id
      @user.last_status_project.should == @project
    end
  end
  
  describe "#related_users" do
    define_models :copy => false do
      model User do
        stub :login => 'default'
        stub :thing_1, :login => 'thing_1', :last_status_at => current_time - 5.days
        stub :thing_2, :login => 'thing_2', :last_status_at => current_time - 3.days
        stub :the_cat, :login => 'the_cat'
      end
      
      model Project do
        stub :default, :name => 'default'
        stub :other, :name => 'other'
      end
      
      model Membership do
        stub :default, :user => all_stubs(:user), :project => all_stubs(:project)
        stub :other, :project => all_stubs(:other_project)
        stub :thing_1, :user => all_stubs(:thing_1_user)
        stub :thing_1_on_other, :user => all_stubs(:thing_1_user), :project => all_stubs(:other_project)
        stub :thing_2, :user => all_stubs(:thing_2_user), :project => all_stubs(:other_project)
      end
    end
    
    it "sorts #last_status_at" do
      users(:default).related_users.should == [users(:thing_2), users(:thing_1)]
    end
  end

  it 'creates users as !admin' do
    create_user.should_not be_admin
  end

  it 'being created increments User.count' do
    method(:create_user).should change(User, :count).by(1)
  end

  it 'resets password' do
    users(:default).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate(users(:default).login, 'new password').should == users(:default)
  end

  it 'does not rehash password' do
    users(:default).update_attributes(:login => users(:default).login.reverse)
    User.authenticate(users(:default).login, 'test').should == users(:default)
  end

  it 'authenticates user' do
    User.authenticate(users(:default).login, 'test').should == users(:default)
  end

  it 'sets remember token' do
    users(:default).remember_me
    users(:default).remember_token.should_not be_nil
    users(:default).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    users(:default).remember_me
    users(:default).remember_token.should_not be_nil
    users(:default).forget_me
    users(:default).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    users(:default).remember_me_for 1.week
    after = 1.week.from_now.utc
    users(:default).remember_token.should_not be_nil
    users(:default).remember_token_expires_at.should_not be_nil
    users(:default).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    users(:default).remember_me_until time
    users(:default).remember_token.should_not be_nil
    users(:default).remember_token_expires_at.should_not be_nil
    users(:default).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    users(:default).remember_me
    after = 2.weeks.from_now.utc
    users(:default).remember_token.should_not be_nil
    users(:default).remember_token_expires_at.should_not be_nil
    users(:default).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'suspends user' do
    users(:default).suspend!
    users(:default).should be_suspended
  end

  it 'does not authenticate suspended user' do
    users(:default).suspend!
    User.authenticate('quentin', 'test').should_not == users(:default)
  end

  it 'unsuspends user' do
    users(:suspended).unsuspend!
    users(:suspended).should be_active
  end

  it 'deletes user' do
    users(:default).deleted_at.should be_nil
    users(:default).delete!
    users(:default).deleted_at.should_not be_nil
    users(:default).should be_deleted
  end
  
  it 'finds owned projects' do
    users(:default).owned_projects.should == [projects(:another), projects(:default)]
  end
  
  it 'adds self as a member to the owned_projects after creation' do
    project = users(:default).owned_projects.create(:name => 'Ninjas')
    users(:default).projects.should include(project)
    project.memberships.should_not be_empty
  end
  
protected
  def create_user(options = {})
    User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
  end
end