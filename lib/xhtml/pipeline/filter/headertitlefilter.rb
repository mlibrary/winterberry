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
              :xhtml_header_title,
              XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      return unless issue.name == name

      super(
              issue,
              options: options
           )

      if issue.content.name == 'title'
        content = (issue.content.text || "").strip
        if content.empty? or content == "Header Title"
          m = epub.rendition.metadata.dc.elements.title.first.text
          issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                    name: issue.name,
                    reference_node: issue.content,
                    action: :replace_content,
                    markup: m,
                    warning_message: "#{issue.name}, #{issue.content.name} no content"
                  )
        end
      end
    end
  end
end
