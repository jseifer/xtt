require File.dirname(__FILE__) + '/../spec_helper'

describe_validations_for Project, :name => 'foo', :user_id => 32 do
  presence_of :name, :user_id
end
