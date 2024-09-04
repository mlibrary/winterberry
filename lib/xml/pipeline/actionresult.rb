module UMPTG::XML::Pipeline

  class ActionResult < UMPTG::Object

    attr_accessor :actions
    attr_reader :modified

    def initialize(args = {})
      super(args)

      @actions = @properties.key?(:actions) ? @properties[:actions] : []
      @modified = @properties.key?(:modified) ? @properties[:modified] : false
    end
  end
end
