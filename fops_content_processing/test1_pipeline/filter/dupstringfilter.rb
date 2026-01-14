module Test1Pipeline

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

      act = DupStringAction.new(
                  issue,
                  options: options
                )
      act.add_info_msg("#{@name}, found issue #{issue.name}")
      issue.actions << act
    end
  end
end
