require 'rubygems'

dir = File.dirname(__FILE__)
rails_app_spec = "#{dir}/../../../../config/environment.rb"
vendor_rspec   = "#{dir}/../../rspec/lib"

if File.exist?(vendor_rspec)
  $:.unshift vendor_rspec
else
  gem 'rspec'
end

if File.exist?(rails_app_spec)
  require rails_app_spec
  Time.zone = "UTC"
end

$:.unshift "#{dir}/../lib"

require 'ruby-debug'
require 'spec'
require 'can_filter_by_dates'

Debugger.start