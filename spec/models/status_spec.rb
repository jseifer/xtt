require File.dirname(__FILE__) + '/../spec_helper'

describe Status do
  define_models :default
  
  it "#user retrieves associated User" do
    statuses(:default).user.should == users(:default)
  end
end

describe_validations_for Status, :user_id => 1, :message => 'foo bar' do
  presence_of :user_id, :message
end