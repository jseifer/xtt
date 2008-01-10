require File.dirname(__FILE__) + '/../spec_helper'

describe_validations_for User, 
  :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' do
    presence_of :login, :password, :password_confirmation, :email
end

describe User do
  define_models :users

  describe "being bootstrapped" do
    define_models :bootstrap, :copy => false do
      model User
    end
  
    it "creates initial user as admin" do
      create_user.should be_admin
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
  
  it 'finds owned groups' do
    users(:default).owned_groups.should == [groups(:default)]
  end
  
  it 'adds self as a member to the owned_group after creation' do
    group = users(:default).owned_groups.create(:name => 'Ninjas')
    users(:default).groups.should include(group)
    group.memberships.should_not be_empty
  end
  
  it 'collects owned projects and group projects in #all_projects' do
    users(:default).all_projects.should include(projects(:default))
    users(:default).all_projects.should include(projects(:another))
  end
  
protected
  def create_user(options = {})
    User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
  end
end