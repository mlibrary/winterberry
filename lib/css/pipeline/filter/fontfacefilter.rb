module UMPTG::CSS::Pipeline

  class FontFaceFilter < UMPTG::CSS::Pipeline::Filter

    def initialize(args = {})
      a = args.clone
      a[:name] = :css_font_face
      super(a)
    end

    def run(css_parser, args = {})
      a = args.clone
      actions = []

      actions << UMPTG::CSS::Pipeline::FontFaceAction.new(
                name: a[:name],
                content: css_parser,
                info_msg: "#{a[:name]} action"
            )
      return actions
    end

    def create_actions(args = {})
      name = args[:name]
      return super(args)
    end
  end
end
