module UMPTG::Fulcrum::ResourceMap

  class Action < UMPTG::Object

    attr_reader :reference, :resource, :xpath, :name
    attr_accessor :type

    def initialize(args = {})
      super(args)

      @name = @properties[:name]
      @reference = @properties[:reference]
      @resource = @properties[:resource]
      @type = @properties[:type]
      @xpath = @properties[:xpath]
    end
  end
end
