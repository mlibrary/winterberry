module UMPTG::XML::Pipeline

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
      @status = Action.PENDING
    end

    def self.process_actions(args = {})
      actions = args.key?(:actions) ? args[:actions] : []
      normalize = args.key?(:normalize) ? args[:normalize] : false

      modified = false
      if normalize
        actions.each do |a|
          a.process(args)
          modified = true if a.normalize and a.status == UMPTG::Action.COMPLETED
        end
      end

      return UMPTG::XML::Pipeline::ActionResult.new(
              actions: actions,
              modified: modified
              )
    end

    def self.report_actions(args = {})
      actions = args.key?(:actions) ? args[:actions] : []
      logger = args.key?(:logger) ? args[:logger] : UMPTG::Logger.create(logger_fp: STDOUT)

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
  end
end
