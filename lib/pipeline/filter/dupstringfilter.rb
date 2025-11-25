module UMPTG::Pipeline

  class DupStringFilter < UMPTG::Pipeline::Filter

    def initialize(options: nil)
      super(
            name: :pipeline_dup_string,
            options: options
          )
    end

    def select(content, options: nil)
      issue = UMPTG::Issue.new(
                  name: name,
                  content: content
               )
      return [ issue ]
    end

    def review(issue, options: nil)
      return unless issue.name == name

      act = UMPTG::Pipeline::DupStringAction.new(
                  issue,
                  options: options
                )
      act.add_info_msg("#{@name}, found issue #{issue.name}")
      issue.actions << act
    end

    def process_results(issues, logger:, options: nil)
      super(issues, options: options, logger: logger)

      issues.each {|i| logger.info("#{i.name}, new content=\"#{i.content}\"")}
    end
  end
end
