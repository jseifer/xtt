require File.dirname(__FILE__) + '/../spec_helper'

describe_validations_for Group, :name => 'foo', :owner_id => 1 do
  uniqueness_of :name
  presence_of :name, :owner_id
end

describe Group do
  define_models
  
  it "accesses owner" do
    groups(:default).owner.should == users(:default)
  end
end