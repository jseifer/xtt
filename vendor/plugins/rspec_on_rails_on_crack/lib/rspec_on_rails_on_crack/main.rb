module Spec::Extensions::Main
  def describe_validations_for(model, attributes, &block)
    describe model, "(validations)" do
      before :all do
        @attributes = attributes
      end
      
      before do
        @record = model.new
      end
      
      RspecOnRailsOnCrack::ValidationExampleProxy.new(self, model).instance_eval(&block)
    end
  end
end

module RspecOnRailsOnCrack
  class ValidationExampleProxy
    def initialize(example_group, model)
      @example_group, @model = example_group, model
    end

    def presence_of(*attributes)
      it.validates_presence_of(@model, *attributes)
    end
    
    def uniqueness_of(*attributes)
      it.validates_uniqueness_of(@model, *attributes)
    end
    
  protected
    def it
      @example_group.it
    end
  end
end