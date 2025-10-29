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

      actions << UMPTG::CSS::Pipeline::Action.new(
                name: a[:name],
                content: css_parser
            )
      return actions
    end

    def create_actions(args = {})
      name = args[:name]
      css_class = args[:css_class]
      puts css_class.class
      return super(args)
    end
  end
end
