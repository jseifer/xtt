require File.dirname(__FILE__) + '/../spec_helper'

describe_validations_for Account, :host => 'foo' do
  uniqueness_of :host
  presence_of :host
end

describe Account do
  it "downcases #host" do
    account = Account.new
    account.host = "FOO"
    account.host.should == 'foo'
  end
end