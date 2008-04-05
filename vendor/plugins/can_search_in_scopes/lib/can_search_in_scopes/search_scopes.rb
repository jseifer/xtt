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
      if scope_class = self.class.scope_types[options[:scope]]
        scope = scope_class.new(@model, name, options)
        (@scopes_by_type[scope_class] ||= []) << scope
        @scopes[name] = scope
      end
    end

    def search_for(options = {})
      @scopes.values.inject(@model) { |finder, scope| scope.scope_for(finder, options) }
    end

    def [](name)
      @scopes[name]
    end
  end
  
  class BaseScope
    attr_reader :name, :attribute, :finder_name, :model
    def initialize(model, name, options = {})
      @model, @name = model, name
    end
    
    # strip out any scoped keys from options and return a chained finder.
    def scope_for(finder, options = {})
      finder
    end

    def ==(other)
      self.class == other.class && other.name == @name && other.attribute == @attribute && other.finder_name == @finder_name
    end
  end
  
  class ReferenceScope < BaseScope
    attr_reader :singular_name
    def initialize(model, name, options = {})
      super
      single         = name.to_s.singularize
      @singular_name = single.to_sym
      @attribute     = options[:attribute]   || single.foreign_key.to_sym
      @finder_name   = options[:finder_name] || "by_#{name}".to_sym
      @model.named_scope @finder_name, lambda { |records| {:conditions => {@attribute => records}} }
    end

    def scope_for(finder, options = {})
      value, values = options.delete(@singular_name), options.delete(@name) || []
      values << value if value
      return finder if values.empty?
      finder.send(@finder_name, values.size == 1 ? values.first : values)
    end
    
    def ==(other)
      super && other.singular_name == @singular_name
    end
  end

  SearchScopes.scope_types[:reference] = ReferenceScope
end

send respond_to?(:require_dependency) ? :require_dependency : :require, 'can_search_in_scopes/date_range_scope'