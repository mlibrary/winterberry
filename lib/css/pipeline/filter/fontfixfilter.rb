module UMPTG::CSS::Pipeline

  class FontFixFilter < UMPTG::CSS::Pipeline::Filter

    def initialize(args = {})
      a = args.clone
      a[:name] = :css_font_fix
      super(a)
    end

    def run(css_parser, args = {})
      a = args.clone
      actions = []

      css_parser.match(/^body[ ]+\{/) do |md|
        actions << UMPTG::CSS::Pipeline::FontFixAction.new(
                name: a[:name],
                content: css_parser,
                match_data: md,
                info_message: "#{a[:name]}, found #{md[0]}"
              )
      end

=begin
      css_parser.match(/font-family:[^;]+/) do |md|
        actions << UMPTG::XML::Pipeline::Action.new(
                  name: a[:name],
                  info_message: "#{a[:name]}, found #{md[0]}"
              )
      end
=end
      return actions
    end
  end
end
