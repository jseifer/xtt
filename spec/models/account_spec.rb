require File.dirname(__FILE__) + '/../spec_helper'

describe_validations_for Account, :host => 'foo' do
  uniqueness_of :host
  presence_of :host
end

describe Account do
  define_models

  it "downcases #host" do
    account = Account.new
    account.host = "FOO"
    account.host.should == 'foo'
  end
  
  it "checks user existence" do
    accounts(:default).users.include?(users(:default)).should == true
    User.update_all :account_id => nil
    accounts(:default).users.include?(users(:default)).should == false
  end
end