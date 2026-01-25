module UMPTG::CSS::Pipeline

  class TimesFontFilter < UMPTG::Pipeline::Filter

    def initialize(options: nil)
      super(
              name: :css_times_font,
              options: options
            )
    end

    def resolve(issue, options: {})
      return unless issue.name == name

      super(
              issue,
              options: options
           )

      name = issue.name

      issue.actions << UMPTG::CSS::Pipeline::TimesFontAction.new(
                name: a[:name],
                content: issue.content
            )

    end
  end
end
