module UMPTG::Fulcrum::ResourceMap

  class Action

    attr_reader :reference, :resource
    attr_accessor :type

    def initialize(args = {})
      @reference = args[:reference]
      @resource = args[:resource]
      @type = args[:type]
    end
  end
end