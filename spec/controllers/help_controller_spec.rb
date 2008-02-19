require File.dirname(__FILE__) + '/../spec_helper'

describe HelpController, "GET #index" do
  # fixture definition

  act! { get :index }

  before do
    @help = []
    Help.stub!(:find).with(:all).and_return(@help)
  end
  
  it_assigns :help
  it_renders :template, :index

  describe HelpController, "(xml)" do
    # fixture definition
    
    act! { get :index, :format => 'xml' }

    it_assigns :help
    it_renders :xml, :help
  end

  describe HelpController, "(json)" do
    # fixture definition
    
    act! { get :index, :format => 'json' }

    it_assigns :help
    it_renders :json, :help
  end


end

describe HelpController, "GET #show" do
  # fixture definition

  act! { get :show, :id => 1 }

  before do
    @help  = help(:default)
    Help.stub!(:find).with('1').and_return(@help)
  end
  
  it_assigns :help
  it_renders :template, :show
  
  describe HelpController, "(xml)" do
    # fixture definition
    
    act! { get :show, :id => 1, :format => 'xml' }

    it_renders :xml, :help
  end

  describe HelpController, "(json)" do
    # fixture definition
    
    act! { get :show, :id => 1, :format => 'json' }

    it_renders :json, :help
  end


end

describe HelpController, "GET #new" do
  # fixture definition
  act! { get :new }
  before do
    @help  = Help.new
  end

  it "assigns @help" do
    act!
    assigns[:help].should be_new_record
  end
  
  it_renders :template, :new
  
  describe HelpController, "(xml)" do
    # fixture definition
    act! { get :new, :format => 'xml' }

    it_renders :xml, :help
  end

  describe HelpController, "(json)" do
    # fixture definition
    act! { get :new, :format => 'json' }

    it_renders :json, :help
  end


end

describe HelpController, "POST #create" do
  before do
    @attributes = {}
    @help = mock_model Help, :new_record? => false, :errors => []
    Help.stub!(:new).with(@attributes).and_return(@help)
  end
  
  describe HelpController, "(successful creation)" do
    # fixture definition
    act! { post :create, :help => @attributes }

    before do
      @help.stub!(:save).and_return(true)
    end
    
    it_assigns :help, :flash => { :notice => :not_nil }
    it_redirects_to { help_path(@help) }
  end

  describe HelpController, "(unsuccessful creation)" do
    # fixture definition
    act! { post :create, :help => @attributes }

    before do
      @help.stub!(:save).and_return(false)
    end
    
    it_assigns :help
    it_renders :template, :new
  end
  
  describe HelpController, "(successful creation, xml)" do
    # fixture definition
    act! { post :create, :help => @attributes, :format => 'xml' }

    before do
      @help.stub!(:save).and_return(true)
      @help.stub!(:to_xml).and_return("mocked content")
    end
    
    it_assigns :help, :headers => { :Location => lambda { help_url(@help) } }
    it_renders :xml, :help, :status => :created
  end
  
  describe HelpController, "(unsuccessful creation, xml)" do
    # fixture definition
    act! { post :create, :help => @attributes, :format => 'xml' }

    before do
      @help.stub!(:save).and_return(false)
    end
    
    it_assigns :help
    it_renders :xml, "help.errors", :status => :unprocessable_entity
  end

  describe HelpController, "(successful creation, json)" do
    # fixture definition
    act! { post :create, :help => @attributes, :format => 'json' }

    before do
      @help.stub!(:save).and_return(true)
      @help.stub!(:to_json).and_return("mocked content")
    end
    
    it_assigns :help, :headers => { :Location => lambda { help_url(@help) } }
    it_renders :json, :help, :status => :created
  end
  
  describe HelpController, "(unsuccessful creation, json)" do
    # fixture definition
    act! { post :create, :help => @attributes, :format => 'json' }

    before do
      @help.stub!(:save).and_return(false)
    end
    
    it_assigns :help
    it_renders :json, "help.errors", :status => :unprocessable_entity
  end

end

describe HelpController, "GET #edit" do
  # fixture definition
  act! { get :edit, :id => 1 }
  
  before do
    @help  = help(:default)
    Help.stub!(:find).with('1').and_return(@help)
  end

  it_assigns :help
  it_renders :template, :edit
end

describe HelpController, "PUT #update" do
  before do
    @attributes = {}
    @help = help(:default)
    Help.stub!(:find).with('1').and_return(@help)
  end
  
  describe HelpController, "(successful save)" do
    # fixture definition
    act! { put :update, :id => 1, :help => @attributes }

    before do
      @help.stub!(:save).and_return(true)
    end
    
    it_assigns :help, :flash => { :notice => :not_nil }
    it_redirects_to { help_path(@help) }
  end

  describe HelpController, "(unsuccessful save)" do
    # fixture definition
    act! { put :update, :id => 1, :help => @attributes }

    before do
      @help.stub!(:save).and_return(false)
    end
    
    it_assigns :help
    it_renders :template, :edit
  end
  
  describe HelpController, "(successful save, xml)" do
    # fixture definition
    act! { put :update, :id => 1, :help => @attributes, :format => 'xml' }

    before do
      @help.stub!(:save).and_return(true)
    end
    
    it_assigns :help
    it_renders :blank
  end
  
  describe HelpController, "(unsuccessful save, xml)" do
    # fixture definition
    act! { put :update, :id => 1, :help => @attributes, :format => 'xml' }

    before do
      @help.stub!(:save).and_return(false)
    end
    
    it_assigns :help
    it_renders :xml, "help.errors", :status => :unprocessable_entity
  end

  describe HelpController, "(successful save, json)" do
    # fixture definition
    act! { put :update, :id => 1, :help => @attributes, :format => 'json' }

    before do
      @help.stub!(:save).and_return(true)
    end
    
    it_assigns :help
    it_renders :blank
  end
  
  describe HelpController, "(unsuccessful save, json)" do
    # fixture definition
    act! { put :update, :id => 1, :help => @attributes, :format => 'json' }

    before do
      @help.stub!(:save).and_return(false)
    end
    
    it_assigns :help
    it_renders :json, "help.errors", :status => :unprocessable_entity
  end

end

describe HelpController, "DELETE #destroy" do
  # fixture definition
  act! { delete :destroy, :id => 1 }
  
  before do
    @help = help(:default)
    @help.stub!(:destroy)
    Help.stub!(:find).with('1').and_return(@help)
  end

  it_assigns :help
  it_redirects_to { help_path }
  
  describe HelpController, "(xml)" do
    # fixture definition
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it_assigns :help
    it_renders :blank
  end

  describe HelpController, "(json)" do
    # fixture definition
    act! { delete :destroy, :id => 1, :format => 'json' }

    it_assigns :help
    it_renders :blank
  end


end