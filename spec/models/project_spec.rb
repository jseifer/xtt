require File.dirname(__FILE__) + '/../spec_helper'

describe_validations_for Project, :name => 'foo', :parent_id => 32, :parent_type => "Group" do
  presence_of :name, :parent_id, :parent_type
end
