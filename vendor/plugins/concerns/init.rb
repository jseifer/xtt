class << ActiveRecord::Base
  def concerned_with(*concerns)
    concerns.each { |c| require_dependency "#{name.underscore}/#{c}" }
  end
end

require 'ostruct'
require 'md5'
require 'gchart'
require 'has_finder'