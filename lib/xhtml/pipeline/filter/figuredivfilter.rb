module UMPTG::XHTML::Pipeline::Filter

  class FigureDivFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='figure' and @class='image' and @role='group'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_figure_div,
              XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      super(
              issue,
              options: options
           )

      if issue.content.name == 'figure' and issue.content['class'] == 'image' and issue.content['role'] == 'group'
        reference_node = issue.content
        section_node = reference_node.xpath("./ancestor::*[local-name()='section'][1]").first
        unless section_node.nil? or section_node['aria-labelledby'] != 'part01'
          markup = '<div style="display:block">' + reference_node.to_html + '</div>'

          issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                   issue,
                   options: {
                       action: :replace_node,
                       markup: markup,
                       warning_message: \
                         "#{issue.name}, #{reference_node.name} no div wrapper"
                       }
               )
        end
      end
    end
  end
end
