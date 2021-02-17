module UMPTG::Fulcrum::ResourceMap

  class Action < UMPTG::Object

    attr_reader :reference, :resource
    attr_accessor :type

    def initialize(args = {})
      super(args)

      @reference = @properties[:reference]
      @resource = @properties[:resource]
      @type = @properties[:type]
    end
  end
end
