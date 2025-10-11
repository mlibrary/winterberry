module UMPTG::EPUB::NCX::Pipeline::Filter

  class ContentFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-PCKXPATH
    //*[
    local-name()='content'
    ]
    PCKXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :epub_ncx_content
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      reference_node = args[:reference_node]

      actions = []

      if reference_node.name == "content"
        src = reference_node["src"]
        new_src = UMPTG::XHTML::fix_ext(src)
        unless src == new_src
          actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                    name: name,
                    reference_node: reference_node,
                    attribute_name: "src",
                    attribute_value: new_src,
                    warning_message: "#{name}, found #{reference_node.name}/@src=\"#{src}\""
                  )
        end
      end
      return actions
    end
  end
end
