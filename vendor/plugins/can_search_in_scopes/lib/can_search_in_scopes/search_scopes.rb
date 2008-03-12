module CanSearchInScopes
  class SearchScopes
    def self.scope_types() @scope_types ||= {} end
    
    attr_reader :model, :scopes, :scopes_by_type
  
    def initialize(model, &block)
      @scopes, @scopes_by_type = {}, {}
      @model = model
      @model.extend CanSearchInScopes
      instance_eval(&block) if block
    end
    
    def scoped_by(name, options = {})
      options[:scope] ||= :reference
      scope = self.class.scope_types[options[:scope]].new(name, options)
      (@scopes_by_type[scope.class] ||= []) << scope
      @scopes[name] = scope
    end
    
    def [](name)
      @scopes[name]
    end
  end
  
  class BaseScope
    attr_reader :name, :attribute
    def initialize(name, options = {})
      @name = name
    end
    
    # strip out any scoped keys from options, scope the given search_block with them, and the with_scope options
    def self.scope_options_for(search_scopes, options = {})
    end
    
    def ==(other)
      self.class == other.class && other.name == @name && other.attribute == @attribute
    end
  end
  
  class ReferenceScope < BaseScope
    attr_reader :singular_name
    def initialize(name, options = {})
      super
      single         = name.to_s.singularize
      @singular_name = single.to_sym
      @attribute     = options[:attribute] || single.foreign_key.to_sym
    end
    
    def self.scope_options_for(search_scopes, options = {})
      conditions = search_scopes.scopes_by_type[self].inject({}) do |cond, scope|
        value, values = options.delete(scope.singular_name), options.delete(scope.name) || []
        values << value if value
        if values.size == 1
          cond[scope.attribute] = values.first
        elsif values.size > 1
          cond[scope.attribute] = values
        end
        cond
      end
      conditions.blank? ? nil : {:conditions => conditions}
    end
    
    def ==(other)
      super && other.singular_name == @singular_name
    end
  end
  
  SearchScopes.scope_types[:reference] = ReferenceScope
end

send respond_to?(:require_dependency) ? :require_dependency : :require, 'can_search_in_scopes/date_range_scope'