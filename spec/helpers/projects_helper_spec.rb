require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectsHelper do
  {0.5 => 10, 1 => 10, 3 => 10, 10.5 => 20, 15 => 20}.each do |max, normalized|
    it "#normalized_max([#{max}]).should == #{normalized}" do
      normalized_max([max]).should == normalized
    end
  end
  
  {4 => [0,1,2,3,4], 19 => [0, 5, 10, 15], 50 => [0, 10, 20, 30, 40, 50], 70 => [0, 20, 40, 60], 105 => [0, 25, 50, 75, 100]}.each do |max, range|
    it "#normalized_range(#{max}).should == #{range.inspect}" do
      normalized_range(max).should == range
    end
  end
end