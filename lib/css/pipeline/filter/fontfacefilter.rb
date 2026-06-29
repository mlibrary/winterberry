module UMPTG::CSS::Pipeline

  class FontFaceFilter < UMPTG::Pipeline::Filter

    def initialize(options: nil)
      super(
              name: :css_font_face,
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

      issue.actions << UMPTG::CSS::Pipeline::FontFaceAction.new(
                name: name,
                content: issue.content,
                info_msg: "#{a[:name]} action"
            )
    end
  end
end
