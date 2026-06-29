module UMPTG::XHTML::Pipeline::Filter

  class HeaderClassFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    @class='chsubsect2'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_header_class,
              XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      super(
              issue,
              options: options
           )

      if issue.content['class'] == 'chsubsect2'
=begin
        action = UMPTG::XML::Pipeline::Action.new(
                issue,
                options: {
                    info_message: \
                      "#{issue.name}, #{issue.content.name} found #{issue.content['class']}"
                    }
            )
=end
        action = UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                issue,
                options: {
                    name: issue.name,
                    reference_node: issue.content,
                    attribute_name: "class",
                    attribute_value: "chsubsect",
                    warning_message: \
                      "#{issue.name}, #{issue.content.name} found @class=\"#{issue.content['class']}\""
                  }
            )
        issue.actions << action
      end
    end
  end
end
