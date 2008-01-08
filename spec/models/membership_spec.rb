require File.dirname(__FILE__) + '/../spec_helper'

describe Membership do
  define_models :memberships do
    model Membership
  end
  
  it "knows arbitrary users are not group members" do
    groups(:default).users.should_not include(users(:default))
  end
  
  it "adds users as group members" do
    Membership.create! :user => users(:default), :group => groups(:default)
    groups(:default).users.should include(users(:default))
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