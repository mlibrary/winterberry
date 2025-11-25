module UMPTG::Pipeline

  class Filter < UMPTG::Object

    attr_reader :name

    def initialize(name:, options: nil)
      super(name: name)
      @name = name
    end

=begin
    def run(content:, options:)
      a = options.clone()
      a[:name] = @name

      issues = select(content, options: options)
      issues.each {|i| review(i, options: options) }
      return issues
    end
=end

    def select(content, options: {})
      return []
    end

    def review(issue, options: {})
      act = UMPTG::Pipeline::Action.new(issue, options: options)
      act.add_info_msg("#{@name}, found issue #{issue.name}")
      issue.actions << act
    end

    def process_results(issues, logger:, options: {})
      actions_cnt = completed_cnt = warning_cnt = error_cnt = 0
      issues.each do |issue|
        issue.actions.each do |a|
          actions_cnt += 1
          completed_cnt += 1 if a.normalize and a.status == UMPTG::Action.COMPLETED
          a.messages.each {|m| warning_cnt += 1 if m.level == UMPTG::Message.WARNING }
          a.messages.each {|m| error_cnt += 1 if m.level == UMPTG::Message.ERROR }
        end
      end
      logger.info("#{@name}, actions=#{actions_cnt}, completed=#{completed_cnt}, warnings=#{warning_cnt}, errors=#{error_cnt}")
    end
  end

  rq_path = File.join(File.expand_path(File.dirname(__FILE__)), "filter", "*")
  Dir.glob(rq_path).each {|f| require_relative(f) }

  FILTERS = {
        pipeline_string_length: UMPTG::Pipeline::StringLengthFilter,
        pipeline_dup_string: UMPTG::Pipeline::DupStringFilter
      }

  def self.FILTERS
    return FILTERS
  end
end
