require File.dirname(__FILE__) + '/../spec_helper'

describe ContextsController, "GET #index" do
  act! { get :index }
  
  it_redirects_to { root_path }
end

describe ContextsController, "GET #show" do
  before do
    @context    = 'c'
    @statuses   = []
    @date_range = [1.week.ago, 2.weeks.ago]
    @hours      = 75.0
    @user       = mock_model User, :id => 5
    User.stub!(:find_by_permalink).with('5').and_return(@user)
    @context.stub!(:to_xml).and_return("<context></context>")
    @context.stub!(:statuses).and_return(@statuses)
    controller.stub!(:login_required)
    @user = mock_model(User, :id => 55, :active? => true, :time_zone => "UTC", :contexts => [])
    @user.contexts.stub!(:find_by_permalink).with('1').and_return(@context)
    controller.stub!(:current_user).and_return(@user)
  end

  [ {:user_id => nil,   :filter => nil, :args => [nil, :weekly, {:date => nil, :context => 'c', :page => nil, :per_page => 20, :current_user => 55}]},
    {:user_id => 'all', :filter => nil, :args => [nil, :weekly, {:date => nil, :context => 'c', :page => nil, :per_page => 20, :current_user => 55}]},
    {:user_id => 'me',  :filter => nil, :args => [55,  :weekly, {:date => nil, :context => 'c', :page => nil, :per_page => 20, :current_user => 55}]},
    {:user_id => '5',   :filter => nil, :args => [5,   :weekly, {:date => nil, :context => 'c', :page => nil, :per_page => 20, :current_user => 55}]},
    {:user_id => nil,   :filter => 'weekly', :args => [nil, 'weekly', {:date => nil, :context => 'c', :page => nil, :per_page => 20, :current_user => 55}]},
    {:user_id => 'all', :filter => 'weekly', :args => [nil, 'weekly', {:date => nil, :context => 'c', :page => nil, :per_page => 20, :current_user => 55}]},
    {:user_id => 'me',  :filter => 'weekly', :args => [55,  'weekly', {:date => nil, :context => 'c', :page => nil, :per_page => 20, :current_user => 55}]},
    {:user_id => '5',   :filter => 'weekly', :args => [5,   'weekly', {:date => nil, :context => 'c', :page => nil, :per_page => 20, :current_user => 55}]} ].each do |options|
      
    describe ContextsController, "(filtered)" do
      define_models :contexts
      
      act! { get :show, options.merge(:id => 1) }
      
      before(:each) do
        Status.should_receive(:filter).with(*options[:args]).and_return([@statuses, @date_range])
        Status.should_receive(:filter_all_users).and_return([@statuses, @date_range])
        Status.should_receive(:filtered_hours).with(*options[:args][0..-3] + [:daily, {:date => nil, :context => 'c', :current_user => 55}]).and_return(@hours)
        Status.should_receive(:filtered_hours).with(*options[:args][0..-2] + [{:date => nil, :context => 'c', :current_user => 55}]).and_return(@hours)
      end
      
      it_assigns :statuses, :date_range, :hours
      it_renders :template, :show, :pending => true # Don't integrate views yet -- we're using "real" contexts

      describe ContextsController, "(xml)" do
        define_models :contexts
        
        act! { get :show, options.merge(:id => 1, :format => 'xml') }
      
        it_renders :xml, :context
      end if options[:user_id].nil? && options[:filter].nil?
    end
  end
end