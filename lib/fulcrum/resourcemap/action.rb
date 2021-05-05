module UMPTG::Fulcrum::ResourceMap

  class Action < UMPTG::Object

    attr_reader :reference, :resource
    attr_accessor :type, :element_type, :reference_selector, :reference_entry

    def initialize(args = {})
      super(args)

      @reference = @properties[:reference]
      @resource = @properties[:resource]
      @type = @properties[:type]
      @element_type = @properties[:element_type]
      @reference_entry = @properties[:reference_entry]
      @reference_selector = @properties[:reference_selector]
    end
  end
end
