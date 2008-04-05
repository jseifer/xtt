module CanSearchInScopes
  def self.extended(base)
    class << base
      attr_accessor :search_scopes
    end
  end
  
  def search(options = {})
    options = options.dup
    scope_for(options).send(options.key?(:page) ? :paginate : :all, options)
  end

  def scope_for(options = {})
    search_scopes.scope_for(options)
  end
end