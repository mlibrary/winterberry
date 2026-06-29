module UMPTG::CSS::Pipeline

  class FontFixFilter < UMPTG::Pipeline::Filter

    def initialize(options: nil)
      super(
              name: :css_font_fix,
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

      issue.content.match(/^body[ ]+\{/) do |md|
        issue.actions << UMPTG::CSS::Pipeline::FontFixAction.new(
                name: a[:name],
                content: issue.content,
                match_data: md,
                info_message: "#{a[:name]}, found #{md[0]}"
              )
      end
=begin
      issue.content.match(/font-family:[^;]+/) do |md|
        issue.actions << UMPTG::XML::Pipeline::Action.new(
                  name: a[:name],
                  info_message: "#{a[:name]}, found #{md[0]}"
              )
      end
=end
    end
  end
end
