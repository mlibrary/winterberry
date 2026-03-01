module UMPTG::Pipeline

  class Action < UMPTG::Action
    attr_reader :issue, :normalize, :options

    def initialize(issue, options: {})
      super(
            issue: issue,
            options: options
          )

      @issue = issue
      @normalize = false
      @options = options
    end

    def resolve(options: {})
      super(
          issue: @issue,
          options: options
        )
      @status = Action.PENDING
    end

    def self.resolve_issues(issues, logger:, options: {})
      normalize = options[:normalize] || false
      display_msgs = options[:display_msgs] || false

      modified = false
      if normalize
        issues.each do |issue|
          issue.actions.each do |a|
            a.resolve(options: options)
            modified = modified or (a.normalize and a.status == UMPTG::Action.COMPLETED)
          end
        end
      end
      if display_msgs
        UMPTG::Pipeline::Action.display_messages(
              issues,
              logger: logger
           )
      end

      return UMPTG::Pipeline::ActionResult.new(
              issues,
              modified: modified
              )
    end

    def self.display_messages(issues, logger:)
      issues.each do |issue|
        issue.actions.each do |action|
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
end
