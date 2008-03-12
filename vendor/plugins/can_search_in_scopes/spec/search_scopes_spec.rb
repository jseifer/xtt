require File.dirname(__FILE__) + '/spec_helper'

module CanSearchInScopes
  describe SearchScopes do
    it "creates default reference scope" do
      Record.search_scopes[:parents].should == \
        ReferenceScope.new(:parents, :attribute => :parent_id, :singular => :parent, :scope => :reference)
    end
    
    it "creates default date range scope" do
      Record.search_scopes[:created].should == \
        DateRangeScope.new(:created, :attribute => :created_at, :scope => :date_range)
    end
    
    it "creates date range scope with custom attribute" do
      Record.search_scopes[:range].should == \
        DateRangeScope.new(:range, :attribute => :created_at, :scope => :date_range)
    end
    
    describe "filtering records" do
      it "shows recent records with no filter" do
        compare_records Record.search(:order => 'created_at desc'), [:default, :day, :week_1, :week_2, :biweek_1, :biweek_2, :month_1, :month_2, :archive]
      end
      
      it "paginates if :page is given" do
        pending "no will_paginate?" unless Record.respond_to?(:paginate)
        compare_records Record.search(:page => 2, :order => 'created_at desc'), [:week_2, :biweek_1, :biweek_2]
      end
      
      it "filters by :parents singular option" do
        compare_records Record.search(:order => 'created_at desc', :parent => 2), [:day, :week_2, :biweek_1, :month_1]
      end
      
      it "filters by :parents singular option and actual record" do
        compare_records Record.search(:order => 'created_at desc', :parent => records(:day)), [:day, :week_2, :biweek_1, :month_1]
      end
      
      it "filters by :parents plural option" do
        compare_records Record.search(:order => 'created_at desc', :parents => %w(1 2)), [:default, :day, :week_1, :week_2, :biweek_1, :biweek_2, :month_1, :month_2, :archive]
      end
      
      it "filters by :parents singular and plural options" do
        compare_records Record.search(:order => 'created_at desc', :parent => 1, :parents => %w(2 5)), [:default, :day, :week_1, :week_2, :biweek_1, :biweek_2, :month_1, :month_2, :archive]
      end

      it "filters statuses by date_range" do
        compare_records Record.search(:order => 'created_at desc', :created => (@now-5.days..@now-7.minutes)), [:day, :week_1, :week_2]
      end

      it "filters today's statuses" do
        compare_records Record.search(:order => 'created_at desc', :created => {:period => :daily}), [:default, :day]
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