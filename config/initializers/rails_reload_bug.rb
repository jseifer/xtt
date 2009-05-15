class << ActiveRecord::Base
  # Rails 2.3.2 bug w/ threadsafe code
  #def scoped_methods
  #  Thread.current[:"#{self}_scoped_methods"] ||= (self.default_scoping || []).dup
  #end
  
  # lighthouse ticket #1339 - causes epic memleak in development mode, but fixes the reloading issue.
  def reset_subclasses
    $stderr.puts "**I RELOAD **"
    
    nonreloadables = []
    subclasses.each do |klass|
      unless ActiveSupport::Dependencies.autoloaded? klass
        $stderr.puts "**I DO NOT RELOAD #{klass} **"
        nonreloadables << klass
        next
      end
    #  klass.instance_variables.each { |var| klass.send(:remove_instance_variable, var) }
    #  klass.instance_methods(false).each { |m| klass.send :undef_method, m }
    end
    @@subclasses = {}
    nonreloadables.each { |klass| (@@subclasses[klass.superclass] ||= []) << klass }
  end
end