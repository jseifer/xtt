module CanSearchInScopes
  def self.extended(base)
    class << base
      attr_accessor :search_scopes
    end
  end
  
  def search(options = {})
    options = options.dup
    search_for(options).send(options.key?(:page) ? :paginate : :all, options)
  end

  def search_for(options = {})
    search_scopes.search_for(options)
  end
end