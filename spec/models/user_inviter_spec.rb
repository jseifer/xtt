require File.dirname(__FILE__) + '/../spec_helper'

describe User::Inviter do
  define_models :copy => false do
    model User do
      stub :login => 'default', :email => 'default@email.com'
      stub :foo, :login => 'foo', :email => 'baz@email.com'
      stub :bar, :login => 'bar', :email => 'bar@email.com'
    end
    
    model Project do
      stub :name => 'project'
    end
    
    model Membership
  end
  
  before do
    @inviter = User::Inviter.new(projects(:default).id, "FOO, bar , BAZ@email.com , newb@email.com")
  end

  it "parses logins" do
    @inviter.logins.should == %w(foo bar)
  end
  
  it "parses emails" do
    @inviter.emails.should == %w(baz@email.com newb@email.com)
  end
  
  it "shows new emails" do
    @inviter.new_emails.should == %w(newb@email.com)
  end
  
  it "retrieves unique users" do
    @inviter.users.should == [users(:foo), users(:bar)]
  end
  
  it "creates memberships and emails users" do
    @inviter.users.each do |user|
      User::Mailer.should_receive(:deliver_project_invitation).with(@inviter.project, user)
    end
    lambda { @inviter.invite }.should change(Membership, :count).by(2)
  end
end