module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class TestFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    name()='dc:title'
    ]
    SXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :epub_oebps_test
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # <dc.title> element

      action_list = []

      case reference_node.name
      when 'title'
        action_list << UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: reference_node,
                 info_message: "#{name}, found #{reference_node}"
             )
      end

      return action_list
    end
  end
end
