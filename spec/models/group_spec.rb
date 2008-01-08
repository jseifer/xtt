require File.dirname(__FILE__) + '/../spec_helper'

describe_validations_for Group, :name => 'foo' do
  uniqueness_of :name
  presence_of :name
end

describe Group do
  define_models
  
  it "checks user existence" do
    groups(:default).users.include?(users(:default)).should == true
    User.update_all :group_id => nil
    groups(:default).users.include?(users(:default)).should == false
  end
end