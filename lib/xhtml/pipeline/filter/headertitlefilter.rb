module UMPTG::XHTML::Pipeline::Filter

  class HeaderTitleFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='head'
    ]/*[
    local-name()='title'
    ]
    SXPATH

    def initialize(options: nil)
      super(
              name: :xhtml_header_title,
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
      reference_node = issue.content  # <title> element

      if reference_node.name == 'title'
        content = (reference_node.text || "").strip
        if content.empty? or content == "Header Title"
          m = epub.rendition.metadata.dc.elements.title.first.text
          issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                    name: name,
                    reference_node: reference_node,
                    action: :replace_content,
                    markup: m,
                    warning_message: "#{name}, #{reference_node.name} no content"
                  )
        end
      end
    end
  end
end
