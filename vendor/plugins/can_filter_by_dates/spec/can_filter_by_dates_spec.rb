require File.dirname(__FILE__) + '/spec_helper'

CanFilterByDates.filters[:spec] = lambda do |now|
  (now..now + 300)
end

describe CanFilterByDates do
  before do
    @old_tz = ENV['TZ']
    ENV['TZ'] = "UTC"
  end
  
  after do
    ENV['TZ'] = @old_tz
  end

  describe "#with_date_filter(filter, now = nil, &block) with ActiveSupport defaults" do
    it "creates daily range" do
      pending "No :daily filter, do you have ActiveSupport loaded?" unless CanFilterByDates.filters.key?(:daily)
      check_filter :daily, Time.utc(2008, 1, 1, 12), (Time.local(2008, 1, 1)..Time.local(2008, 1, 2))
    end

    it "creates weekly range" do
      pending "No :weekly filter, do you have ActiveSupport loaded?" unless CanFilterByDates.filters.key?(:weekly)
      check_filter :weekly, Time.utc(2008, 1, 1), (Time.local(2007, 12, 31)..Time.local(2008, 1, 7))
    end

    it "creates bi-weekly range for first half of the month" do
      pending "No :'bi-weekly' filter, do you have ActiveSupport loaded?" unless CanFilterByDates.filters.key?(:'bi-weekly')
      check_filter :'bi-weekly', Time.utc(2008, 1, 5), (Time.local(2008, 1, 1)..Time.local(2008, 1, 15))
    end

    it "creates bi-weekly range for second half of the month" do
      pending "No :'bi-weekly' filter, do you have ActiveSupport loaded?" unless CanFilterByDates.filters.key?(:'bi-weekly')
      check_filter :'bi-weekly', Time.utc(2008, 1, 16), (Time.local(2008, 1, 15)..Time.local(2008, 2, 1)-1)
    end

    it "creates monthly range" do
      pending "No :monthly filter, do you have ActiveSupport loaded?" unless CanFilterByDates.filters.key?(:monthly)
      check_filter :monthly, Time.utc(2008, 1, 5), (Time.local(2008, 1, 1)..Time.local(2008, 2, 1)-1)
    end
  end
  
  describe "#with_date_filter(filter, now = nil, &block)" do
    it "parses time and calls #with_date_range with valid filter" do
      check_filter :spec, '2008-1-1', (Time.local(2008, 1, 1)..Time.local(2008, 1, 1, 0, 5))
    end
    
    it "returns block result and nil range with nil filter" do
      with_date_filter(:attr, nil, nil) { 5 }.should == [5, nil]
    end
    
    it "raises exception on bad filter" do
      lambda { with_date_filter(:attr, :snozzberries, nil) { 5 } }.should raise_error(RuntimeError)
    end
  end

  describe "#parse_filtered_time(time_or_string)" do
    it "converts strings to times" do
      parse_filtered_time("2008-1-1").should == Time.local(2008, 1, 1)
    end
    
    it "converts times to utc" do
      time   = Time.now
      time.should_not be_utc
      parsed = parse_filtered_time(time)
      parsed.should == time
      parsed.should be_utc
    end
    
    it "raises error on bad filtered date value" do
      lambda { parse_filtered_time(:boom) }.should raise_error(RuntimeError)
    end
  end

  def check_filter(filter, input, expected_range)
    block = lambda { 5 }
    should_receive(:with_date_range).with(:attr, expected_range).and_return(75)
    with_date_filter(:attr, filter, input, &block).should == [75, expected_range]
  end
end