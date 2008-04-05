require File.dirname(__FILE__) + '/spec_helper'

module CanSearchInScopes
  describe "all Reference Scopes", :shared => true do
    include CanSearchSpecHelper

    it "instantiates reference scope" do
      Record.search_scopes[@scope.name].should == @scope
    end

    it "creates named_scope" do
      Record.scopes[@scope.finder_name].should_not be_nil
    end

    it "paginates records" do
      compare_records Record.search(:page => nil, @scope.name => [2]), [:day, :week_2, :biweek_1]
    end
    
    it "filters records with plural value from named_scope" do
      compare_records Record.search(@scope.name => [2]), [:day, :week_2, :biweek_1, :month_1]
    end
    
    it "filters records with singular value from named_scope" do
      compare_records Record.search(@scope.singular_name => 2), [:day, :week_2, :biweek_1, :month_1]
    end
    
    it "filters records with plural record value from named_scope" do
      compare_records Record.search(@scope.name => [records(:day)]), [:day, :week_2, :biweek_1, :month_1]
    end
    
    it "filters records with singular record value from named_scope" do
      compare_records Record.search(@scope.singular_name => records(:day)), [:day, :week_2, :biweek_1, :month_1]
    end
  end

  describe SearchScopes do
    describe "(Reference Scope with no options)" do
      before do
        Record.can_search do
          scoped_by :parents
        end
        @scope = ReferenceScope.new(Record, :parents, :attribute => :parent_id, :singular => :parent, :scope => :reference, :finder_name => :by_parents)
      end

      it_should_behave_like "all Reference Scopes"
    end

    describe "(Reference Scope with custom attribute)" do
      before do
        Record.can_search do
          scoped_by :masters, :attribute => :parent_id
        end
        @scope = ReferenceScope.new(Record, :masters, :attribute => :parent_id, :singular => :master, :scope => :reference, :finder_name => :by_masters)
      end

      it_should_behave_like "all Reference Scopes"
    end

    describe "(Reference Scope with custom attribute and finder name)" do
      before do
        Record.can_search do
          scoped_by :masters, :attribute => :parent_id, :finder_name => :great_scott
        end
        @scope = ReferenceScope.new(Record, :masters, :attribute => :parent_id, :singular => :master, :scope => :reference, :finder_name => :great_scott)
      end

      it_should_behave_like "all Reference Scopes"
    end

    #describe "filters" do
    #  it "recent records with no filter" do
    #    compare_records Record.search, [:default, :day, :week_1, :week_2, :biweek_1, :biweek_2, :month_1, :month_2, :archive]
    #  end
    #
    #  it "recent records with nil date range period" do
    #    compare_records Record.search(:created => {:period => nil}), [:default, :day, :week_1, :week_2, :biweek_1, :biweek_2, :month_1, :month_2, :archive]
    #  end
    #  
    #  it "statuses by date_range" do
    #    compare_records Record.search(:created => (@now-5.days..@now-7.minutes)), [:day, :week_1, :week_2]
    #  end
    #
    #  it "today's records" do
    #    compare_records Record.search(:created => {:period => :daily}), [:default, :day]
    #  end
    #
    #  it "daily records" do
    #    compare_records Record.search(:created => {:period => :daily, :start => @now - 3.days}), [:week_1]
    #  end
    #  
    #  it "this week's records" do
    #    compare_records Record.search(:created => {:period => :weekly}), [:default, :day, :week_1, :week_2]
    #  end
    #  
    #  it "this fortnight's records" do
    #    compare_records Record.search(:created => {:period => :'bi-weekly'}), [:default, :day, :week_1, :week_2, :biweek_1, :biweek_2]
    #  end
    #  
    #  it "earlier fortnight's records" do
    #    compare_records Record.search(:created => {:period => :'bi-weekly', :start => '2007-6-14 6:00:00'}), [:month_1, :month_2]
    #  end
    #  
    #  it "this month's records" do
    #    compare_records Record.search(:created => {:period => :monthly}), [:default, :day, :week_1, :week_2, :biweek_1, :biweek_2, :month_1, :month_2]
    #  end
    #  
    #  it "older month's records" do
    #    compare_records Record.search(:created => {:period => :monthly, :start => '2007-5-5'}), [:archive]
    #  end
    #  

    #end
  end
end