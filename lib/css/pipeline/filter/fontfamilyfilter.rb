module UMPTG::CSS::Pipeline

  class FontFamilyFilter < UMPTG::CSS::Pipeline::Filter

    def initialize(args = {})
      a = args.clone
      a[:name] = :css_font_family
      super(a)
    end

    def run(css_parser, args = {})
      a = args.clone
      actions = []

      actions << UMPTG::CSS::Pipeline::FontFamilyAction.new(
              name: a[:name],
              content: css_parser
            )
=begin
      ndx = css_parser.index(/font-family:/)
      ndx2 = css_parser.index(/[\n]+/, ndx)
      puts "#{ndx},#{ndx2}"
      actions << UMPTG::CSS::Pipeline::TimesFontAction.new(
                name: a[:name],
                content: css_parser
            )
=end
      return actions
    end
  end
end
