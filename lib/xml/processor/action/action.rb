module UMPTG::XML::Processor::Action

  class Action < UMPTG::Action
    attr_reader :name, :normalize, :reference_node

    def initialize(args = {})
      super(args)

      @name = @properties[:name]
      @reference_node = @properties[:reference_node]
      @action_node = @properties[:action_node]
      @normalize = false
    end

    def process(args = {})
      super(args)
      @status = Action.COMPLETED
    end
  end
end
