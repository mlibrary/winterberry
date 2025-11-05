module UMPTG::CSS::Pipeline

  class TimesFontFilter < UMPTG::CSS::Pipeline::Filter

    def initialize(args = {})
      a = args.clone
      a[:name] = :css_times_font
      super(a)
    end

    def run(css_parser, args = {})
      a = args.clone
      actions = []

      actions << UMPTG::CSS::Pipeline::TimesFontAction.new(
                name: a[:name],
                content: css_parser
            )
      return actions
    end
  end
end
