module UMPTG::EPUB::NCX::Pipeline::Filter

  class TestFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='navPoint'
    ]/*[
    local-name()='content'
    ]
    SXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :ncx_test
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # <navPoint/content> element

      action_list = []

      case reference_node.name
      when 'content'
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
