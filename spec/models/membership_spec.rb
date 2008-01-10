require File.dirname(__FILE__) + '/../spec_helper'

describe Membership do
  define_models :memberships do
    model Membership
  end
  
  it "knows arbitrary users are not group members" do
    groups(:default).owner_id = nil
    groups(:default).users.include?(users(:default)).should == false
  end
  
  it "recognizes group owners as members" do
    groups(:default).users.include?(users(:default)).should == true
  end
  
  it "adds users as group members" do
    groups(:default).owner_id = nil
    Membership.create! :user => users(:default), :group => groups(:default)
    groups(:default).users.include?(users(:default)).should == true
  end

  it "doesn't allow duplicates" do
    Membership.create!(:user_id => 1, :group_id => 1)
    m = Membership.new :user_id => 1, :group_id => 1
    m.should_not be_valid
  end
end

describe_validations_for Membership, :user_id => 1, :group_id => 1 do
  presence_of :user_id, :group_id
end