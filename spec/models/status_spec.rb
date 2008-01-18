require File.dirname(__FILE__) + '/../spec_helper'

describe Status do
  define_models :statuses
  
  it "#user retrieves associated User" do
    statuses(:default).user.should == users(:default)
  end
  
  it "#next retrieves followup status" do
    statuses(:in_project).followup.should == statuses(:pending)
  end
  
  it "adjusts followup time with accesor" do
    time = 5.minutes.from_now
    statuses(:pending).created_at.should_not == time
    statuses(:in_project).followup_time = time
    statuses(:in_project).save
    statuses(:pending).reload.created_at.should == time
  end
  
  it "#next retrieves previous status" do
    statuses(:pending).previous.should == statuses(:in_project)
  end
  
  it "rounds down to the nearest 5 minutes" do
    statuses(:default).fixed_created_at = "2008-01-01 15:34:00 UTC"
    statuses(:default).created_at.should == Time.parse("2008-01-01 15:30:00 UTC")
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
    @status.hours.to_f.should == 5.0
  end
  
  it "caches User#last_status_id" do
    @new.save!
    @status.user.reload.last_status.should == @new
  end
  
  it "caches User#last_status_message" do
    @new.save!
    @status.user.reload.last_status_message.should == @new.message
  end
  
  it "caches User#last_status_project_id" do
    @new.project = projects(:default)
    @new.save!
    @status.user.reload.last_status_project.should == @new.project
  end
  
  it "caches User#last_status_at" do
    @new.save!
    @status.user.reload.last_status_at.should == @new.created_at
  end
end

describe Status, "in pending state" do
  define_models :copy => :statuses do
    model Status do
      stub :new, :message => 'howdy', :created_at => (current_time - 2.hours), :project => all_stubs(:project)
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

describe Status, "(filtering)" do
  define_models

  it "finds statuses by user" do
    users(:default).statuses.should == [statuses(:in_project), statuses(:default)]
  end
  
  it "finds statuses by project" do
    projects(:default).statuses.should == [statuses(:in_project)]
    Status.for_project(projects(:default)).should == [statuses(:in_project)]
  end
  
  it "finds statuses without project" do
    Status.without_project.should == [statuses(:default)]
  end
  
  it "finds user statuses by project" do
    users(:default).statuses.for_project(projects(:default)).should == [statuses(:in_project)]
  end
  
  it "finds user statuses without project" do
    users(:default).statuses.without_project.should == [statuses(:default)]
  end
end

describe_validations_for Status, :user_id => 1, :message => 'foo bar' do
  presence_of :user_id, :message
end