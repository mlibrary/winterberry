module UMPTG::Review

  class Action < UMPTG::Action
    attr_reader :name, :reference_node, :review_msg_list

    def initialize(args = {})
      super(args)

      @name = @properties[:name]
      @reference_node = @properties[:reference_node]
      @action_node = @properties[:action_node]

      @review_msg_list = []

      add_info_msg(@properties[:info_message]) if @properties.key?(:info_message)
      add_warning_msg(@properties[:warning_message]) if @properties.key?(:warning_message)
      add_error_msg(@properties[:error_message]) if @properties.key?(:error_message)
      add_fatal_msg(@properties[:fatal_message]) if @properties.key?(:fatal_message)
    end

    def process(args = {})
      super(args)
      @status = Action.COMPLETED
    end

    def to_s
      return @review_msg_list.join("\n")
    end

    def add_msg(args = {})
      raise "Missing :level parameter" unless args.key?(:level)
      raise "Missing :text parameter" unless args.key?(:text)

      @review_msg_list << UMPTG::Message.new(
                level: args[:level],
                text: args[:text]
              )
    end

    def add_info_msg(txt = "")
      add_msg(
          level: UMPTG::Message.INFO,
          text: txt
      )
    end

    def add_warning_msg(txt = "")
      add_msg(
          level: UMPTG::Message.WARNING,
          text: txt
      )
    end

    def add_error_msg(txt = "")
      add_msg(
          level: UMPTG::Message.ERROR,
          text: txt
      )
    end

    def add_fatal_msg(txt = "")
      add_msg(
          level: UMPTG::Message.FATAL,
          text: txt
      )
    end
  end
end
