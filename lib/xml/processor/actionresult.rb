module UMPTG::XML::Processor

  class ActionResult < UMPTG::Object

    attr_reader :actions, :modified

    def initialize(args = {})
      super(args)

      @actions = @properties.key?(:actions) ? @properties[:actions] : []
      @modified = @properties.key?(:modified) ? @properties[:modified] : false
    end
  end
end
