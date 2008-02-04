require File.dirname(__FILE__) + '/../spec_helper'

describe Status do
  define_models :statuses
  # define_models :users
  
  it "#user retrieves associated User" do
    statuses(:default).user.should == users(:default)
  end
  
  it "#next retrieves followup status" do
    statuses(:in_project).followup.should == statuses(:pending)
  end
  
  it "sets finished_at to the same day, or after, as created_at" do
    Time.zone = "UTC"
    s = statuses(:in_project)
    puts s.created_at
    s.set_finished_at = "14:34"
    s.finished_at.should == "1234"
  end
  
  #it "adjusts followup time with accessor" do
  #  time = 5.minutes.from_now
  #
  #  statuses(:pending).created_at.should_not == time
  #  statuses(:pending).followup.should be_nil
  #
  #  s = statuses(:in_project)
  #  s.followup.should == statuses(:pending)
  #  s.followup.should_receive(:update_attribute).with(:created_at, time)
  #
  #  s.followup_time = time.to_s
  #  s.should be_valid
  #end
  #
  #it "does not allow setting followup time past the next status' finish time" do
  #  time = 5.minutes.from_now
  #  # order goes default -> in_project -> pending 
  #  # so setting default.followup_time has to check all the way to 'pending' to ensure it
  #  # doesn't exceed its bounds.
  #  statuses(:in_project).followup.should == statuses(:pending) # created 47 hours ago
  #  statuses(:default).followup.should == statuses(:in_project) # created 48 hours ago
  #  statuses(:default).should be_valid
  #
  #  statuses(:default).followup_time = statuses(:pending).created_at + 1.second
  #  statuses(:default).should_not be_valid
  #end

  it "sets the correct time" do
    u = users(:default) #mock_model(User, :id => '1')
    s1 = Status.create! :created_at => "Fri Jan 18 2008 00:00:00", :user => u, :message => "foo", :project_id => 1
    s2 = Status.create! :created_at => "Fri Jan 19 2008 00:00:00", :user => u, :message => "bar", :project_id => 1
    s3 = Status.create! :created_at => "Fri Jan 20 2008 00:00:00", :user => u, :message => "bar", :project_id => 1    
    
    s1.followup(true).should == s2
    
    s1.attributes = {
      "set_created_at" => "Fri Jan 18 2008 12:45:01 GMT-0800 (PST)"
      #{}"followup_time"  => "Fri Jan 19 2008 12:45:01 GMT-0800 (PST)"
    }
    
    s1.created_at.should == Time.parse("2008-01-18 20:45:01 UTC").utc
    #s2.reload.created_at.should == Time.parse("2008-01-19 20:45:01 UTC").utc
  end


  it "does not allow time travel backwards" do
    statuses(:in_project).previous.should == statuses(:default)
    lambda{
      statuses(:in_project).set_created_at = statuses(:default).created_at.utc - 10.minutes
      statuses(:in_project).errors.on(:created_at).should_not be_nil
    }.should_not change { statuses(:in_project).created_at }
    
    #}.should change { statuses(:in_project).valid? }.to(false)
    #statuses(:in_project).should_not be_valid
  end
  
  #it "assigns date if the input string is from javascript" do
  #  statuses(:default).followup_time = "2008-12-12 00:00:00 GMT-0800"
  #  statuses(:in_project).reload.created_at.should == Time.parse("2008-12-12 08:00:00 UTC")
  #end
  
  it "assigns created-at to utc if input string is from javascript" do
    statuses(:default).set_created_at = "2008-12-12 00:00:00 GMT-0800 (PST)"
    statuses(:default).created_at.should == Time.parse("2008-12-12 08:00:00 UTC").utc
  end
  
  it "#next retrieves previous status" do
    statuses(:pending).previous.should == statuses(:in_project)
  end
  
  #it "rounds down to the nearest 5 minutes" do
  #  statuses(:default).fixed_created_at = "2008-01-01 15:34:00 UTC"
  #  statuses(:default).created_at.should == Time.parse("2008-01-01 15:30:00 UTC")
  #end
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
    @new.previous(true).should    == @status
    @status.followup.should == @new
  end
  
  it "processes previous status when creating" do
    @status.should be_pending
    @status.should be_valid
    @new.save!
    @status.reload
    @status.should be_processed
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

describe Status, "(filtering by date)" do
  define_models :copy => false do
    time 2007, 6, 30, 6
    model Status do
      stub :message => 'default', :state => 'processed', :hours => 5, :created_at => current_time - 5.minutes, :user_id => 5
      stub :status_day,      :created_at => current_time - 8.minutes, :user_id => 3
      stub :status_week_1,   :created_at => current_time - 3.days
      stub :status_week_2,   :created_at => current_time - (4.days + 20.hours), :user_id => 3
      stub :status_biweek_1, :created_at => current_time - 8.days, :user_id => 3
      stub :status_biweek_2, :created_at => current_time - (14.days + 20.hours)
      stub :status_month_1,  :created_at => current_time - 20.days, :user_id => 3
      stub :status_month_2,  :created_at => current_time - (28.days + 20.hours)
      stub :archive, :created_at => current_time - 35.days
    end
  end
  
  before do
    @old = Time.zone
    Time.zone = -28800
  end
  
  after do
    Time.zone = @old
  end
  
  it "shows recent statuses with no filter" do
    compare_arrays Status.filter(nil, nil),  [:default, :status_day, :status_week_1, :status_week_2,
      :status_biweek_1, :status_biweek_2, :status_month_1, :status_month_2, :archive]
  end
  
  it "shows recent statuses by user" do
    compare_arrays Status.filter(5, nil),  [:default, :status_week_1,  :status_biweek_2, :status_month_2, :archive]
  end
  
  it "shows today's statuses" do
    compare_arrays Status.filter(nil, 'daily'),  [:default, :status_day]
  end
  
  it "shows today's statuses by user" do
    compare_arrays Status.filter(5, 'daily'),  [:default]
  end
  
  it "shows this week's statuses" do
    compare_arrays Status.filter(nil, 'weekly'),  [:default, :status_day, :status_week_1, :status_week_2]
  end
  
  it "shows this week's statuses by user" do
    compare_arrays Status.filter(5, 'weekly'),  [:default, :status_week_1]
  end
  
  it "shows this fortnight's statuses" do
    compare_arrays Status.filter(nil, 'bi-weekly'),  [:default, :status_day, :status_week_1, :status_week_2, :status_biweek_1, :status_biweek_2]
  end
  
  it "shows this fortnight's statuses by user" do
    compare_arrays Status.filter(5, 'bi-weekly'),  [:default, :status_week_1, :status_biweek_2]
  end
  
  it "shows earlier fortnight's statuses" do
    Time.stub!(:now).and_return(Time.utc(2007, 6, 14, 6))
    compare_arrays Status.filter(nil, 'bi-weekly'),  [:status_month_1, :status_month_2]
  end
  
  it "shows earlier fortnight's statuses by user" do
    Time.stub!(:now).and_return(Time.utc(2007, 6, 14, 6))
    compare_arrays Status.filter(5, 'bi-weekly'),  [:status_month_2]
  end
  
  it "shows this month's statuses" do
    compare_arrays Status.filter(nil, 'monthly'),  [:default, :status_day, :status_week_1, :status_week_2, :status_biweek_1, :status_biweek_2, :status_month_1, :status_month_2]
  end
  
  it "shows this month's statuses by user" do
    compare_arrays Status.filter(5, 'monthly'),  [:default, :status_week_1, :status_biweek_2, :status_month_2]
  end
  
  def compare_arrays(actual, expected)
    puts expected.inspect
    expected.each do |e| 
      a_index = actual.index(statuses(e))
      e_index = expected.index(e)
      if a_index.nil?
        fail "Record #{e.inspect} was not in the array, but should have been"
      else
        fail "Record #{e.inspect} is in wrong position: #{a_index.inspect} instead of #{e_index.inspect}" unless a_index == e_index
      end
    end
    
    actual.size.should == expected.size
  end
end

describe_validations_for Status, :user_id => 1, :message => 'foo bar' do
  presence_of :user_id, :message
end