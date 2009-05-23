require File.dirname(__FILE__) + '/../spec_helper'

describe Job::UserInviter do
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
    model Invitation
  end

  before do
    @project = projects(:default)
    @string  = "FOO, bar , BAZ@email.com , newb@email.com"
    @inviter = User::Inviter.new(@project.permalink, @string)
  end
  
  it "sends email to a user" do
    job = Job::UserInviter.new @project, user = @inviter.users[0]
    User::Mailer.should_receive(:deliver_project_invitation).with(@inviter.project, user)
    job.perform
  end
  
  it "sends invitation email to a non-user" do
    job = Job::UserInviter.new @project, invite = @inviter.invitations[0]
    User::Mailer.should_receive(:deliver_new_invitation).with(@inviter.project, invite)
    job.perform
  end
    
end
