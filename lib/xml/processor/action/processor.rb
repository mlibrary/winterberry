module UMPTG::XML::Processor::Action

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

    return UMPTG::XML::Processor::ActionResult.new(
            actions: actions,
            modified: modified
            )
  end
  
  def self.report_actions(args = {})
    actions = args.key?(:actions) ? args[:actions] : []
    logger = args.key?(:logger) ? args[:logger] : UMPTG::Logger.create(logger_fp: STDOUT)

    type_cnt = {
          UMPTG::Message.INFO => 0,
          UMPTG::Message.WARNING => 0,
          UMPTG::Message.ERROR => 0,
          UMPTG::Message.FATAL => 0
    }
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
        type_cnt[msg.level] += 1
      end
    end
  end
end
