require File.dirname(__FILE__) + '/../spec_helper'

describe Membership do
  define_models :memberships do
    model Membership
  end
  
  it "knows arbitrary users are not project members" do
    projects(:default).user_id = nil
    projects(:default).users.include?(users(:default)).should == false
  end
  
  it "recognizes project owners as members" do
    projects(:default).users.include?(users(:default)).should == true
  end
  
  it "adds users as project members" do
    projects(:default).user_id = nil
    Membership.create! :user => users(:default), :project => projects(:default)
    projects(:default).users.include?(users(:default)).should == true
  end

  it "doesn't allow duplicates" do
    Membership.create!(:user_id => 1, :project_id => 1)
    m = Membership.new :user_id => 1, :project_id => 1
    m.should_not be_valid
  end
end

describe_validations_for Membership, :user_id => 1, :project_id => 1 do
  presence_of :user_id, :project_id
end