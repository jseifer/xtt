require File.dirname(__FILE__) + '/spec_helper'

module CanSearchInScopes
  describe SearchScopes do
    it "creates default reference scope" do
      Record.search_scopes[:parents].should == \
        ReferenceScope.new(:parents, :attribute => :parent_id, :singular => :parent, :scope => :reference)
    end

    it "creates default reference scope with custom attribute" do
      Record.search_scopes[:masters].should == \
        ReferenceScope.new(:masters, :attribute => :parent_id, :singular => :master, :scope => :reference)
    end
    
    it "creates default date range scope" do
      Record.search_scopes[:created].should == \
        DateRangeScope.new(:created, :attribute => :created_at, :scope => :date_range)
    end
    
    it "creates date range scope with custom attribute" do
      Record.search_scopes[:range].should == \
        DateRangeScope.new(:range, :attribute => :created_at, :scope => :date_range)
    end
    
    describe "filters" do
      it "searches record with only Reference scopes" do
        RefRecord.search(:limit => 1).first.name.should == records(:default).name
      end

      it "searches record with only DateRange scopes" do
        DateRecord.search(:limit => 1).first.name.should == records(:default).name
      end

      it "recent records with no filter" do
        compare_records Record.search, [:default, :day, :week_1, :week_2, :biweek_1, :biweek_2, :month_1, :month_2, :archive]
      end

      it "recent records with nil date range period" do
        compare_records Record.search(:created => {:period => nil}), [:default, :day, :week_1, :week_2, :biweek_1, :biweek_2, :month_1, :month_2, :archive]
      end
      
      it "if :page is given" do
        pending "no will_paginate?" unless Record.respond_to?(:paginate)
        compare_records Record.search(:page => 2, :order => 'created_at desc'), [:week_2, :biweek_1, :biweek_2]
      end
      
      it "by :parents singular option" do
        compare_records Record.search(:parent => 2), [:day, :week_2, :biweek_1, :month_1]
      end
      
      it "by :parents singular option and actual record" do
        compare_records Record.search(:parent => records(:day)), [:day, :week_2, :biweek_1, :month_1]
      end
      
      it "by :parents plural option" do
        compare_records Record.search(:parents => %w(1 2)), [:default, :day, :week_1, :week_2, :biweek_1, :biweek_2, :month_1, :month_2, :archive]
      end
      
      it "by :parents singular and plural options" do
        compare_records Record.search(:parent => 1, :parents => %w(2 5)), [:default, :day, :week_1, :week_2, :biweek_1, :biweek_2, :month_1, :month_2, :archive]
      end

      it "statuses by date_range" do
        compare_records Record.search(:created => (@now-5.days..@now-7.minutes)), [:day, :week_1, :week_2]
      end

      it "today's records" do
        compare_records Record.search(:created => {:period => :daily}), [:default, :day]
      end

      it "daily records" do
        compare_records Record.search(:created => {:period => :daily, :start => @now - 3.days}), [:week_1]
      end
      
      it "this week's records" do
        compare_records Record.search(:created => {:period => :weekly}), [:default, :day, :week_1, :week_2]
      end
      
      it "this fortnight's records" do
        compare_records Record.search(:created => {:period => :'bi-weekly'}), [:default, :day, :week_1, :week_2, :biweek_1, :biweek_2]
      end
      
      it "earlier fortnight's records" do
        compare_records Record.search(:created => {:period => :'bi-weekly', :start => '2007-6-14 6:00:00'}), [:month_1, :month_2]
      end
      
      it "this month's records" do
        compare_records Record.search(:created => {:period => :monthly}), [:default, :day, :week_1, :week_2, :biweek_1, :biweek_2, :month_1, :month_2]
      end
      
      it "older month's records" do
        compare_records Record.search(:created => {:period => :monthly, :start => '2007-5-5'}), [:archive]
      end

      before :all do
        @now = Time.utc 2007, 6, 30, 6
        Record.connection.create_table :can_search_records, :force => true do |t|
          t.string   :name
          t.integer  :parent_id
          t.datetime :created_at
        end
        Record.connection.add_index :can_search_records, :name
        Record.transaction do
          Record.create :name => 'default',  :parent_id => 1, :created_at => @now - 5.minutes
          Record.create :name => 'day',      :parent_id => 2, :created_at => @now - 8.minutes
          Record.create :name => 'week_1',   :parent_id => 1, :created_at => @now - 3.days
          Record.create :name => 'week_2',   :parent_id => 2, :created_at => @now - (4.days + 20.hours)
          Record.create :name => 'biweek_1', :parent_id => 2, :created_at => @now - 8.days
          Record.create :name => 'biweek_2', :parent_id => 1, :created_at => @now - (14.days + 20.hours)
          Record.create :name => 'month_1',  :parent_id => 2, :created_at => @now - 20.days
          Record.create :name => 'month_2',  :parent_id => 1, :created_at => @now - (28.days + 20.hours)
          Record.create :name => 'archive',  :parent_id => 1, :created_at => @now - 35.days
        end
        @expected_index = Record.find(:all).inject({}) { |h, r| h.update r.name.to_sym => r }
      end
      
      before do
        Time.stub!(:now).and_return(@now)
      end
      
      after :all do
        Record.connection.drop_table :can_search_records
      end
      
      def records(key)
        @expected_index[key]
      end
  
      def compare_records(actual, expected)
        actual = actual.sort { |x, y| y.created_at <=> x.created_at }
        expected.each do |e| 
          a_index = actual.index(records(e))
          e_index = expected.index(e)
          if a_index.nil?
            fail "Record record(#{e.inspect}) was not in the array, but should have been."
          else
            fail "Record record(#{e.inspect}) is in wrong position: #{a_index.inspect} instead of #{e_index.inspect}" unless a_index == e_index
          end
        end
        
        actual.size.should == expected.size
      end
    end
  end
end