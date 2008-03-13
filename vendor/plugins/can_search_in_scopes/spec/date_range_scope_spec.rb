require File.dirname(__FILE__) + '/spec_helper'

module CanSearchInScopes
  DateRangeScope.periods[:spec] = lambda do |now|
    (now..now + 300)
  end

  describe DateRangeScope do
    describe "#with_date_period(filter, now = nil, &block) with ActiveSupport defaults" do
      it "creates daily range" do
        pending "No :daily filter, do you have ActiveSupport loaded?" unless DateRangeScope.periods.key?(:daily)
        check_filter :daily, Time.utc(2008, 1, 1, 12), (Time.utc(2008, 1, 1)..Time.utc(2008, 1, 2)-1.second)
      end

      it "creates weekly range" do
        pending "No :weekly filter, do you have ActiveSupport loaded?" unless DateRangeScope.periods.key?(:weekly)
        check_filter :weekly, Time.utc(2008, 1, 1), (Time.utc(2007, 12, 31)..Time.utc(2008, 1, 7)-1.second)
      end

      it "creates bi-weekly range for first half of the month" do
        pending "No :'bi-weekly' filter, do you have ActiveSupport loaded?" unless DateRangeScope.periods.key?(:'bi-weekly')
        check_filter :'bi-weekly', Time.utc(2008, 1, 5), (Time.utc(2008, 1, 1)..Time.utc(2008, 1, 15)-1.second)
      end

      it "creates bi-weekly range for second half of the month" do
        pending "No :'bi-weekly' filter, do you have ActiveSupport loaded?" unless DateRangeScope.periods.key?(:'bi-weekly')
        check_filter :'bi-weekly', Time.utc(2008, 1, 16), (Time.utc(2008, 1, 15)..Time.utc(2008, 2, 1)-1.second)
      end

      it "creates monthly range" do
        pending "No :monthly filter, do you have ActiveSupport loaded?" unless DateRangeScope.periods.key?(:monthly)
        check_filter :monthly, Time.utc(2008, 1, 5), (Time.utc(2008, 1, 1)..Time.utc(2008, 2, 1)-1)
      end
    end
  
    describe "#with_date_period(filter, now = nil, &block)" do
      it "parses time and calls #with_date_range with valid filter" do
        check_filter :spec, '2008-1-1', (Time.utc(2008, 1, 1)..Time.utc(2008, 1, 1, 0, 5))
      end
    
      it "allows custom instance-level filter" do
        Record.date_periods[:custom_spec] = lambda { |now| (now..now + 420) }
        check_filter :custom_spec, '2008-1-1', (Time.utc(2008, 1, 1)..Time.utc(2008, 1, 1, 0, 7))
        Record.date_periods.delete(:custom_spec)
      end
    
      it "returns block result and nil range with nil filter" do
        Record.with_date_period(:attr, nil, nil) { 5 }.should == [5, nil]
      end
    
      it "raises exception on bad filter" do
        lambda { Record.with_date_period(:attr, :snozzberries, nil) { 5 } }.should raise_error(RuntimeError)
      end
    end

    describe "#parse_filtered_time(time_or_string)" do
      it "converts strings to times" do
        DateRangeScope.parse_filtered_time("2008-1-1").should == Time.utc(2008, 1, 1)
      end
    
      it "converts times to utc" do
        time   = Time.now
        time.should_not be_utc
        parsed = DateRangeScope.parse_filtered_time(time)
        parsed.should == time
        parsed.should be_utc
      end
    
      it "raises error on bad filtered date value" do
        lambda { DateRangeScope.parse_filtered_time(:boom) }.should raise_error(RuntimeError)
      end
    end

    def check_filter(filter, input, expected_range)
      block = lambda { 5 }
      range = expected_range.first.in_current_time_zone..expected_range.last.in_current_time_zone
      Record.should_receive(:with_date_range).with(:attr, range).and_return(75)
      Record.with_date_period(:attr, filter, input, &block).should == [75, range]
    end
  end
end