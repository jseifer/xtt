module CanSearchInScopes
  def self.extended(base)
    class << base
      attr_accessor :search_scopes
    end
  end
  
  def search(options = {})
    scope_search(options) do |options|
      if options[:page]
        paginate(options)
      else
        find :all, options
      end
    end
  end

private
  def scope_search(options = {}, &search_block)
    options = options.dup # don't trash the original
    scopes  = []
    CanSearchInScopes::SearchScopes.scope_types.each do |key, scope_class|
      scopes << scope_class.scope_options_for(search_scopes, options)
    end
    scopes.flatten!
    scopes.uniq!
    scopes.compact!

    if scopes.empty?
      yield options
    else
      recursive_with_scope(scopes) { yield options }
    end
  end
  
  def recursive_with_scope(scopes, &default)
    return default.call if scopes.empty?
    with_scope(:find => scopes.shift) do
      recursive_with_scope(scopes, &default)
    end
  end
end