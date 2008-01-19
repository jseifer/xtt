require File.dirname(__FILE__) + '/../spec_helper'

describe FeedsController, "GET #index" do
  # fixture definition

  act! { get :index }

  before do
    @feeds = []
    Feed.stub!(:find).with(:all).and_return(@feeds)
  end
  
  it_assigns :feeds
  it_renders :template, :index

  describe FeedsController, "(xml)" do
    # fixture definition
    
    act! { get :index, :format => 'xml' }

    it_assigns :feeds
    it_renders :xml, :feeds
  end

  describe FeedsController, "(json)" do
    # fixture definition
    
    act! { get :index, :format => 'json' }

    it_assigns :feeds
    it_renders :json, :feeds
  end


end

describe FeedsController, "GET #show" do
  # fixture definition

  act! { get :show, :id => 1 }

  before do
    @feed  = feeds(:default)
    Feed.stub!(:find).with('1').and_return(@feed)
  end
  
  it_assigns :feed
  it_renders :template, :show
  
  describe FeedsController, "(xml)" do
    # fixture definition
    
    act! { get :show, :id => 1, :format => 'xml' }

    it_renders :xml, :feed
  end

  describe FeedsController, "(json)" do
    # fixture definition
    
    act! { get :show, :id => 1, :format => 'json' }

    it_renders :json, :feed
  end


end

describe FeedsController, "GET #new" do
  # fixture definition
  act! { get :new }
  before do
    @feed  = Feed.new
  end

  it "assigns @feed" do
    act!
    assigns[:feed].should be_new_record
  end
  
  it_renders :template, :new
  
  describe FeedsController, "(xml)" do
    # fixture definition
    act! { get :new, :format => 'xml' }

    it_renders :xml, :feed
  end

  describe FeedsController, "(json)" do
    # fixture definition
    act! { get :new, :format => 'json' }

    it_renders :json, :feed
  end


end

describe FeedsController, "POST #create" do
  before do
    @attributes = {}
    @feed = mock_model Feed, :new_record? => false, :errors => []
    Feed.stub!(:new).with(@attributes).and_return(@feed)
  end
  
  describe FeedsController, "(successful creation)" do
    # fixture definition
    act! { post :create, :feed => @attributes }

    before do
      @feed.stub!(:save).and_return(true)
    end
    
    it_assigns :feed, :flash => { :notice => :not_nil }
    it_redirects_to { feed_path(@feed) }
  end

  describe FeedsController, "(unsuccessful creation)" do
    # fixture definition
    act! { post :create, :feed => @attributes }

    before do
      @feed.stub!(:save).and_return(false)
    end
    
    it_assigns :feed
    it_renders :template, :new
  end
  
  describe FeedsController, "(successful creation, xml)" do
    # fixture definition
    act! { post :create, :feed => @attributes, :format => 'xml' }

    before do
      @feed.stub!(:save).and_return(true)
      @feed.stub!(:to_xml).and_return("mocked content")
    end
    
    it_assigns :feed, :headers => { :Location => lambda { feed_url(@feed) } }
    it_renders :xml, :feed, :status => :created
  end
  
  describe FeedsController, "(unsuccessful creation, xml)" do
    # fixture definition
    act! { post :create, :feed => @attributes, :format => 'xml' }

    before do
      @feed.stub!(:save).and_return(false)
    end
    
    it_assigns :feed
    it_renders :xml, "feed.errors", :status => :unprocessable_entity
  end

  describe FeedsController, "(successful creation, json)" do
    # fixture definition
    act! { post :create, :feed => @attributes, :format => 'json' }

    before do
      @feed.stub!(:save).and_return(true)
      @feed.stub!(:to_json).and_return("mocked content")
    end
    
    it_assigns :feed, :headers => { :Location => lambda { feed_url(@feed) } }
    it_renders :json, :feed, :status => :created
  end
  
  describe FeedsController, "(unsuccessful creation, json)" do
    # fixture definition
    act! { post :create, :feed => @attributes, :format => 'json' }

    before do
      @feed.stub!(:save).and_return(false)
    end
    
    it_assigns :feed
    it_renders :json, "feed.errors", :status => :unprocessable_entity
  end

end

describe FeedsController, "GET #edit" do
  # fixture definition
  act! { get :edit, :id => 1 }
  
  before do
    @feed  = feeds(:default)
    Feed.stub!(:find).with('1').and_return(@feed)
  end

  it_assigns :feed
  it_renders :template, :edit
end

describe FeedsController, "PUT #update" do
  before do
    @attributes = {}
    @feed = feeds(:default)
    Feed.stub!(:find).with('1').and_return(@feed)
  end
  
  describe FeedsController, "(successful save)" do
    # fixture definition
    act! { put :update, :id => 1, :feed => @attributes }

    before do
      @feed.stub!(:save).and_return(true)
    end
    
    it_assigns :feed, :flash => { :notice => :not_nil }
    it_redirects_to { feed_path(@feed) }
  end

  describe FeedsController, "(unsuccessful save)" do
    # fixture definition
    act! { put :update, :id => 1, :feed => @attributes }

    before do
      @feed.stub!(:save).and_return(false)
    end
    
    it_assigns :feed
    it_renders :template, :edit
  end
  
  describe FeedsController, "(successful save, xml)" do
    # fixture definition
    act! { put :update, :id => 1, :feed => @attributes, :format => 'xml' }

    before do
      @feed.stub!(:save).and_return(true)
    end
    
    it_assigns :feed
    it_renders :blank
  end
  
  describe FeedsController, "(unsuccessful save, xml)" do
    # fixture definition
    act! { put :update, :id => 1, :feed => @attributes, :format => 'xml' }

    before do
      @feed.stub!(:save).and_return(false)
    end
    
    it_assigns :feed
    it_renders :xml, "feed.errors", :status => :unprocessable_entity
  end

  describe FeedsController, "(successful save, json)" do
    # fixture definition
    act! { put :update, :id => 1, :feed => @attributes, :format => 'json' }

    before do
      @feed.stub!(:save).and_return(true)
    end
    
    it_assigns :feed
    it_renders :blank
  end
  
  describe FeedsController, "(unsuccessful save, json)" do
    # fixture definition
    act! { put :update, :id => 1, :feed => @attributes, :format => 'json' }

    before do
      @feed.stub!(:save).and_return(false)
    end
    
    it_assigns :feed
    it_renders :json, "feed.errors", :status => :unprocessable_entity
  end

end

describe FeedsController, "DELETE #destroy" do
  # fixture definition
  act! { delete :destroy, :id => 1 }
  
  before do
    @feed = feeds(:default)
    @feed.stub!(:destroy)
    Feed.stub!(:find).with('1').and_return(@feed)
  end

  it_assigns :feed
  it_redirects_to { feeds_path }
  
  describe FeedsController, "(xml)" do
    # fixture definition
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it_assigns :feed
    it_renders :blank
  end

  describe FeedsController, "(json)" do
    # fixture definition
    act! { delete :destroy, :id => 1, :format => 'json' }

    it_assigns :feed
    it_renders :blank
  end


end