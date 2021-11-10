module UMPTG::Review

  class Action < UMPTG::Action
    attr_reader :name, :normalize, :reference_node

    def initialize(args = {})
      super(args)

      @name = @properties[:name]
      @reference_node = @properties[:reference_node]
      @action_node = @properties[:action_node]

      @normalize = false

      add_info_msg(@properties[:info_message]) if @properties.key?(:info_message)
      add_warning_msg(@properties[:warning_message]) if @properties.key?(:warning_message)
      add_error_msg(@properties[:error_message]) if @properties.key?(:error_message)
      add_fatal_msg(@properties[:fatal_message]) if @properties.key?(:fatal_message)
    end

    def process(args = {})
      super(args)
      @status = Action.COMPLETED
    end
  end
end
