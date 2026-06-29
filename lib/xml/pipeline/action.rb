module UMPTG::XML::Pipeline

  class Action < UMPTG::Pipeline::Action
    attr_reader :issue, :normalize, :reference_node

    def initialize(issue, options: {})
      super(issue, options: options)

      @reference_node = options[:reference_node]
      @action_node = options[:action_node]
      @normalize = false
    end

    def resolve(options: {})
      super(options: options)
      @status = Action.PENDING
    end

=begin
    def self.resolve(args = {})
      actions = args.key?(:actions) ? args[:actions] : []
      normalize = args[:normalize] || false
      display_msgs = args[:display_msgs] || true

      modified = false
      if normalize
        actions.each do |a|
          a.resolve(args)
          modified = true if a.normalize and a.status == UMPTG::Action.COMPLETED
        end
      end
      if display_msgs
        UMPTG::XML::Pipeline::Action.display_messages(
              actions: actions,
              logger: args[:logger]
           )
      end

      return UMPTG::XML::Pipeline::ActionResult.new(
              actions: actions,
              modified: modified
              )
    end

    def self.display_messages(args = {})
      logger = args[:logger]
      return if logger.nil?

      actions = args.key?(:actions) ? args[:actions] : []
      #logger = args.key?(:logger) ? args[:logger] : UMPTG::Logger.create(logger_fp: STDOUT)

      actions.each do |action|
        action.messages.each do |msg|
          case msg.level
          when UMPTG::Message.INFO
            logger.info(msg.text)
          when UMPTG::Message.WARNING
            logger.warn(msg.text)
          when UMPTG::Message.ERROR
            logger.error(msg.text)
          when UMPTG::Message.FATAL
            logger.fatal(msg.text)
          end
        end
      end
    end

    def self.report_actions(args = {})
      raise "deprecated"
    end
=end
  end
end
