require File.dirname(__FILE__) + '/../spec_helper'

describe_validations_for Project, :name => 'foo', :user_id => 32 do
  presence_of :name, :user_id
end

describe Project do
  
  it "downcases Project#name to #code if empty" do
    p = Project.new :name => "FOO BAR-BAZ"
    p.valid?
    p.code.should == 'foobarbaz'
  end
  
  it "uniquely enforces code" do
    p1 = Project.create! :name => "FOO BAR-BAZ", :user_id => 1
    p1.should be_valid
    p2 = Project.new :name => "FOO BAR-BAZ", :user_id => 2
    p2.should_not be_valid
  end
    
end
