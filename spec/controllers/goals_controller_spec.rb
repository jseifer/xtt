require File.dirname(__FILE__) + '/../spec_helper'

describe GoalsController, "GET #index" do
  # fixture definition

  act! { get :index }

  before do
    @goals = []
    Goal.stub!(:find).with(:all).and_return(@goals)
  end
  
  it_assigns :goals
  it_renders :template, :index

  describe GoalsController, "(xml)" do
    # fixture definition
    
    act! { get :index, :format => 'xml' }

    it_assigns :goals
    it_renders :xml, :goals
  end

  describe GoalsController, "(json)" do
    # fixture definition
    
    act! { get :index, :format => 'json' }

    it_assigns :goals
    it_renders :json, :goals
  end


end

describe GoalsController, "GET #show" do
  # fixture definition

  act! { get :show, :id => 1 }

  before do
    @goal  = goals(:default)
    Goal.stub!(:find).with('1').and_return(@goal)
  end
  
  it_assigns :goal
  it_renders :template, :show
  
  describe GoalsController, "(xml)" do
    # fixture definition
    
    act! { get :show, :id => 1, :format => 'xml' }

    it_renders :xml, :goal
  end

  describe GoalsController, "(json)" do
    # fixture definition
    
    act! { get :show, :id => 1, :format => 'json' }

    it_renders :json, :goal
  end


end

describe GoalsController, "GET #new" do
  # fixture definition
  act! { get :new }
  before do
    @goal  = Goal.new
  end

  it "assigns @goal" do
    act!
    assigns[:goal].should be_new_record
  end
  
  it_renders :template, :new
  
  describe GoalsController, "(xml)" do
    # fixture definition
    act! { get :new, :format => 'xml' }

    it_renders :xml, :goal
  end

  describe GoalsController, "(json)" do
    # fixture definition
    act! { get :new, :format => 'json' }

    it_renders :json, :goal
  end


end

describe GoalsController, "POST #create" do
  before do
    @attributes = {}
    @goal = mock_model Goal, :new_record? => false, :errors => []
    Goal.stub!(:new).with(@attributes).and_return(@goal)
  end
  
  describe GoalsController, "(successful creation)" do
    # fixture definition
    act! { post :create, :goal => @attributes }

    before do
      @goal.stub!(:save).and_return(true)
    end
    
    it_assigns :goal, :flash => { :notice => :not_nil }
    it_redirects_to { goal_path(@goal) }
  end

  describe GoalsController, "(unsuccessful creation)" do
    # fixture definition
    act! { post :create, :goal => @attributes }

    before do
      @goal.stub!(:save).and_return(false)
    end
    
    it_assigns :goal
    it_renders :template, :new
  end
  
  describe GoalsController, "(successful creation, xml)" do
    # fixture definition
    act! { post :create, :goal => @attributes, :format => 'xml' }

    before do
      @goal.stub!(:save).and_return(true)
      @goal.stub!(:to_xml).and_return("mocked content")
    end
    
    it_assigns :goal, :headers => { :Location => lambda { goal_url(@goal) } }
    it_renders :xml, :goal, :status => :created
  end
  
  describe GoalsController, "(unsuccessful creation, xml)" do
    # fixture definition
    act! { post :create, :goal => @attributes, :format => 'xml' }

    before do
      @goal.stub!(:save).and_return(false)
    end
    
    it_assigns :goal
    it_renders :xml, "goal.errors", :status => :unprocessable_entity
  end

  describe GoalsController, "(successful creation, json)" do
    # fixture definition
    act! { post :create, :goal => @attributes, :format => 'json' }

    before do
      @goal.stub!(:save).and_return(true)
      @goal.stub!(:to_json).and_return("mocked content")
    end
    
    it_assigns :goal, :headers => { :Location => lambda { goal_url(@goal) } }
    it_renders :json, :goal, :status => :created
  end
  
  describe GoalsController, "(unsuccessful creation, json)" do
    # fixture definition
    act! { post :create, :goal => @attributes, :format => 'json' }

    before do
      @goal.stub!(:save).and_return(false)
    end
    
    it_assigns :goal
    it_renders :json, "goal.errors", :status => :unprocessable_entity
  end

end

describe GoalsController, "GET #edit" do
  # fixture definition
  act! { get :edit, :id => 1 }
  
  before do
    @goal  = goals(:default)
    Goal.stub!(:find).with('1').and_return(@goal)
  end

  it_assigns :goal
  it_renders :template, :edit
end

describe GoalsController, "PUT #update" do
  before do
    @attributes = {}
    @goal = goals(:default)
    Goal.stub!(:find).with('1').and_return(@goal)
  end
  
  describe GoalsController, "(successful save)" do
    # fixture definition
    act! { put :update, :id => 1, :goal => @attributes }

    before do
      @goal.stub!(:save).and_return(true)
    end
    
    it_assigns :goal, :flash => { :notice => :not_nil }
    it_redirects_to { goal_path(@goal) }
  end

  describe GoalsController, "(unsuccessful save)" do
    # fixture definition
    act! { put :update, :id => 1, :goal => @attributes }

    before do
      @goal.stub!(:save).and_return(false)
    end
    
    it_assigns :goal
    it_renders :template, :edit
  end
  
  describe GoalsController, "(successful save, xml)" do
    # fixture definition
    act! { put :update, :id => 1, :goal => @attributes, :format => 'xml' }

    before do
      @goal.stub!(:save).and_return(true)
    end
    
    it_assigns :goal
    it_renders :blank
  end
  
  describe GoalsController, "(unsuccessful save, xml)" do
    # fixture definition
    act! { put :update, :id => 1, :goal => @attributes, :format => 'xml' }

    before do
      @goal.stub!(:save).and_return(false)
    end
    
    it_assigns :goal
    it_renders :xml, "goal.errors", :status => :unprocessable_entity
  end

  describe GoalsController, "(successful save, json)" do
    # fixture definition
    act! { put :update, :id => 1, :goal => @attributes, :format => 'json' }

    before do
      @goal.stub!(:save).and_return(true)
    end
    
    it_assigns :goal
    it_renders :blank
  end
  
  describe GoalsController, "(unsuccessful save, json)" do
    # fixture definition
    act! { put :update, :id => 1, :goal => @attributes, :format => 'json' }

    before do
      @goal.stub!(:save).and_return(false)
    end
    
    it_assigns :goal
    it_renders :json, "goal.errors", :status => :unprocessable_entity
  end

end

describe GoalsController, "DELETE #destroy" do
  # fixture definition
  act! { delete :destroy, :id => 1 }
  
  before do
    @goal = goals(:default)
    @goal.stub!(:destroy)
    Goal.stub!(:find).with('1').and_return(@goal)
  end

  it_assigns :goal
  it_redirects_to { goals_path }
  
  describe GoalsController, "(xml)" do
    # fixture definition
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it_assigns :goal
    it_renders :blank
  end

  describe GoalsController, "(json)" do
    # fixture definition
    act! { delete :destroy, :id => 1, :format => 'json' }

    it_assigns :goal
    it_renders :blank
  end


end