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
else
  raise "TODO: attempt to load activerecord and activesupport from gems"
  # also, establish connection with sqlite3 or use DB env var as path to database.yml
end

$:.unshift "#{dir}/../lib"

require 'ruby-debug'
require 'spec'
require 'can_search_in_scopes'
require 'can_search_in_scopes/search_scopes'
require 'can_search_in_scopes/date_range_scope'

module CanSearchInScopes
  class Record < ActiveRecord::Base
    set_table_name 'can_search_records'
    
    def self.per_page() 3 end
    
    can_search do
      scoped_by :parents
      scoped_by :masters, :attribute => :parent_id
      scoped_by :created, :scope => :date_range
      scoped_by :range, :attribute => :created_at, :scope => :date_range
    end
  end
end

Debugger.start