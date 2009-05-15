require File.dirname(__FILE__) + '/../spec_helper'

describe HelpController, "GET #index" do
  define_models :helps

  act! { get :index }

  it_renders :template, :index

end