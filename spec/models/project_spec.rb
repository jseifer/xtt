require File.dirname(__FILE__) + '/../spec_helper'

describe_validations_for Project, :name => 'foo', :user_id => 32 do
  presence_of :name, :user_id
end

describe Project do
  it "raises InvalidCodeError on bad codes" do
    lambda { Project.find_by_code("fido") }.should raise_error(Project::InvalidCodeError)
  end
  
  it "downcases Project#name to #code if empty" do
    p = Project.new :name => "FOO BAR-BAZ"
    p.valid?
    p.code.should == 'foobarbaz'
  end
end
