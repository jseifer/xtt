module CanSearchInScopes
  def self.extended(base)
    class << base
      attr_accessor :search_scopes
    end
  end
  
  def search(options = {})
    in_scope(options) do |options|
      if options.key?(:page)
        paginate(options)
      else
        find :all, options
      end
    end
  end
  
  def scoped_calculate(operation, column_name, options = {})
    in_scope(options) do |options|
      calculate operation, column_name, options
    end
  end

  def scoped_count(column_name, options = {})
    scoped_calculate :count, column_name, options
  end

  def scoped_average(column_name, options = {})
    scoped_calculate :avg, column_name, options
  end

  def scoped_minimum(column_name, options = {})
    scoped_calculate :min, column_name, options
  end

  def scoped_maximum(column_name, options = {})
    scoped_calculate :max, column_name, options
  end

  def scoped_sum(column_name, options = {})
    scoped_calculate :sum, column_name, options
  end

private
  def in_scope(options = {}, &search_block)
    options = options.dup # don't trash the original
    scopes  = []
    CanSearchInScopes::SearchScopes.scope_types.each do |key, scope_class|
      scopes << scope_class.scope_options_for(search_scopes, options)
    end
    scopes.flatten!
    scopes.uniq!
    scopes.compact!

    with_recursive_scope(scopes) { yield options }
  end
  
  def with_recursive_scope(scopes, &default)
    return default.call if scopes.empty?
    with_scope(:find => scopes.shift) do
      with_recursive_scope(scopes, &default)
    end
  end
end