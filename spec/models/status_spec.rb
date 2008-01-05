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
  
  it "processes @status hours" do
    @status.hours.should == 0
    @status.should be_pending
    @status.process!
    @status.should be_processed
    @status.hours.should == 3
  end
end

describe_validations_for Status, :user_id => 1, :message => 'foo bar' do
  presence_of :user_id, :message
end