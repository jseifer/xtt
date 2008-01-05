require File.dirname(__FILE__) + '/../spec_helper'

describe User, "#statuses" do
  define_models :statuses

  before do
    @user = users(:default)
  end

  describe User, "(order)" do
    define_models do
      model Status do
        stub :pending, :state => 'pending', :hours => 0, :created_at => current_time - 3.days
      end
    end
    
    it "retrieves associated statuses in reverse-chronological order" do
      @user.statuses.should == [statuses(:default), statuses(:pending)]
    end
  end

  it "retrieves status after given status" do
    @user.statuses.after(statuses(:default)).should == statuses(:pending)
  end
  
  it "retrieves status before given status" do
    @user.statuses.before(statuses(:pending)).should == statuses(:default)
  end
end

describe User do
  define_models :users

  describe User, "being created" do
    define_models :users
  
    before do
      @creating_user = lambda do
        user = create_user
        violated "#{user.errors.full_messages.to_sentence}" if user.new_record?
      end
    end
  
    it 'increments User.count' do
      @creating_user.should change(User, :count).by(1)
    end
  end

  [:login, :password, :password_confirmation, :email].each do |attr|
    it "requires #{attr}" do
      lambda do
        u = create_user attr => nil
        u.errors.on(attr).should_not be_nil
      end.should_not change(User, :count)
    end
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

protected
  def create_user(options = {})
    User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
  end
end