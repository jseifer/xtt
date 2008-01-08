require File.dirname(__FILE__) + '/../spec_helper'

describe_validations_for Project, :name => 'foo', :group_id => 32 do
  presence_of :name, :group_id
end
