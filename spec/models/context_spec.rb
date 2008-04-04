require File.dirname(__FILE__) + '/../spec_helper'

describe Context do
  before(:each) do
    @context = Context.new
  end

  it "should be valid" do
    @context.should be_valid
  end
end
