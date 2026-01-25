module UMPTG::EPUB::NCX::Pipeline::Filter

  class ContentFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-PCKXPATH
    //*[
    local-name()='content'
    ]
    PCKXPATH

    def initialize(options: nil)
      super(
              name: :epub_ncx_content,
              xpath: XPATH,
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
      reference_node = issue.content  # <content> element

      if reference_node.name == "content"
        src = reference_node["src"]
        new_src = UMPTG::XHTML::fix_ext(src)
        unless src == new_src
          issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                    name: name,
                    reference_node: reference_node,
                    attribute_name: "src",
                    attribute_value: new_src,
                    warning_message: "#{name}, found #{reference_node.name}/@src=\"#{src}\""
                  )
        end
      end
    end
  end
end
