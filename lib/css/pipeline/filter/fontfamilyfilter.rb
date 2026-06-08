module UMPTG::CSS::Pipeline

  class FontFamilyFilter < UMPTG::Pipeline::Filter

    def initialize(options: nil)
      super(
              name: :css_font_family,
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

      issue.actions << UMPTG::CSS::Pipeline::FontFamilyAction.new(
                name: name,
                content: issue.content,
                info_msg: "#{a[:name]} action"
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
    end
  end
end
