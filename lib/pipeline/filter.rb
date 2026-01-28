module UMPTG::Pipeline

  FILTERS = {
      }

  def self.FILTERS
    return FILTERS
  end

  class Filter < UMPTG::Object

    attr_reader :name

    def initialize(name:, options: nil)
      super(name: name)
      @name = name
    end

    def select(content, options: {})
      return []
    end

    def resolve(issue, options: {})
      act = UMPTG::Pipeline::Action.new(issue, options: options)
      #act.add_info_msg("#{@name}, found issue #{issue.name}")
      issue.actions << act
    end

    def resolve_all(result, options: {}, logger: nil)
      return result
    end

    def report(issues, logger:, options: {})
      actions_cnt = completed_cnt = warning_cnt = error_cnt = 0
      issues.each do |issue|
        issue.actions.each do |a|
          actions_cnt += 1
          completed_cnt += 1 if a.normalize and a.status == UMPTG::Action.COMPLETED
          a.messages.each do |m|
            warning_cnt += 1 if m.level == UMPTG::Message.WARNING
            error_cnt += 1 if m.level == UMPTG::Message.ERROR
          end
        end
      end
      logger.info("#{@name}, actions=#{actions_cnt}, completed=#{completed_cnt}, warnings=#{warning_cnt}, errors=#{error_cnt}")
    end
  end
end
