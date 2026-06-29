module Test1Pipeline

  class StringLengthFilter < UMPTG::Pipeline::Filter

    def initialize(options: nil)
      super(
            name: :test1_string_length,
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

    def resolve(issue, options: nil)
      return unless issue.name == name

      super(
              issue,
              options: options
           )
      issue.actions.last.add_info_msg("#{name}, issue #{issue.name} has length #{issue.content.length}")
    end
  end
end
