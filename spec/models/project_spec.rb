require File.dirname(__FILE__) + '/../spec_helper'

describe_validations_for Project, :name => 'foo', :account_id => 32 do
  presence_of :name, :account_id
end
