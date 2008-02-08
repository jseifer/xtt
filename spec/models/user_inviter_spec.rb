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
    @project = projects(:default)
    @string  = "FOO, bar , BAZ@email.com , newb@email.com"
    @inviter = User::Inviter.new(@project.id, @string)
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
    @inviter.should have(2).users
    @inviter.users.should include(users(:foo))
    @inviter.users.should include(users(:bar))
  end
  
  it "creates memberships and emails users" do
    @inviter.users.each do |user|
      User::Mailer.should_receive(:deliver_project_invitation).with(@inviter.project, user)
    end
    lambda { @inviter.invite }.should change(Membership, :count).by(2)
  end
  
  it "rejects invalid emails or logins" do
    ['', ', ; cat foo', ', && cat foo ', ', `cat foo`'].each do |extra|
      inviter = User::Inviter.new(@project.id, @string + extra)
      inviter.logins.should == @inviter.logins
      inviter.emails.should == @inviter.emails
      inviter.to_job.should == @inviter.to_job
    end
  end
  
  it "creates valid job string" do
    @inviter.to_job.should == %{script/runner -e test "User::Inviter.invite(#{@project.id}, 'foo, bar, baz@email.com, newb@email.com')"}
  end
end