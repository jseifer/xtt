require File.dirname(__FILE__) + '/../spec_helper'

describe Status do
  define_models :statuses
  
  it "#user retrieves associated User" do
    statuses(:default).user.should == users(:default)
  end
  
  it "#next retrieves followup status" do
    statuses(:default).followup.should == statuses(:pending)
  end
  
  it "#next retrieves previous status" do
    statuses(:pending).previous.should == statuses(:default)
  end
  
  it "is billable if project is billable" do
    projects(:default).should be_billable
    statuses(:default).project.should == projects(:default)
    statuses(:default).should be_billable
  end
  
  it "is not billable if project is not billable" do
    projects(:default).update_attribute(:billable, false)
    statuses(:default).project.should == projects(:default)
    statuses(:default).should_not be_billable
  end
  
  it "is not billable if there is no project" do
    Status.update_all :project_id => nil
    statuses(:default).reload.should_not be_billable
  end
end

describe Status, "being created" do
  define_models :statuses
  
  before do
    @status = statuses(:pending)
    @new    = @status.user.statuses.build(:message => 'howdy')
    @creating_status = lambda { @new.save! }
  end
  
  it "starts in :pending state" do
    @new.save!
    @new.should be_pending
  end
  
  it "increments user statuses count" do
    @creating_status.should change { @status.user.reload.statuses.size }.by(1)
  end
  
  it "is related properly to the previous status" do
    @new.save!
    @new.previous.should    == @status
    @status.followup.should == @new
  end
  
  it "processes previous status" do
    @status.should be_pending
    @new.save!
    @status.reload.should be_processed
    @status.hours.should == 5
  end
end

describe Status, "in pending state" do
  define_models :copy => :statuses do
    model Status do
      stub :new, :message => 'howdy', :created_at => (current_time - 2.hours)
    end
  end
  
  before do
    @new    = statuses(:new)
    @status = statuses(:pending)
  end
  
  it "#next retrieves next status" do
    @status.followup.should == statuses(:new)
  end
  
  it "skips processing if no followup is found" do
    @status.followup = :false
    @status.hours.should == 0
    @status.should be_pending
    @status.process!
    @status.should be_pending
  end
  
  {0 => 0, 10 => 0.25, 15 => 0.25, 25 => 0.5, 30 => 0.5, 45 => 0.75}.each do |min, result|
    it "processes @status hours in quarters at #{min} minutes past the hour" do
      @new.created_at = @new.created_at + min.minutes
      @new.save

      @status.hours.should == 0
      @status.should be_pending
      @status.process!
      @status.should be_processed
      @status.hours.to_s.should == (3.to_f + result).to_s
    end
  end
  
  it "does no process @status hours if not billable" do
    Status.update_all :project_id => nil
    @status.reload
    @status.process!
    @status.should be_processed
    @status.hours.should == 0
  end
end

describe Status, 'permissions' do
  define_models do
    model User do
      stub :other, :login => 'other'
      stub :admin, :login => 'admin'
    end
  end
  
  before do
    @status = statuses :default
  end
  
  it "allow status owner to edit" do
    @status.should be_editable_by(users(:default))
  end
  
  it "restrict other user from editing" do
    @status.should_not be_editable_by(users(:other))
  end
  
  it "restrict nil user from editing" do
    @status.should_not be_editable_by(nil)
  end
end

describe_validations_for Status, :user_id => 1, :message => 'foo bar' do
  presence_of :user_id, :message
end