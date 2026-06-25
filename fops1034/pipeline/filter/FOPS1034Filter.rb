module UMPTG::XHTML::Pipeline::Filter

  class FOPS1034Filter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='figure'
    and @data-fulcrum-embed-filename
    ]//*[
    local-name()='span'
    and @class='default-media-display'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_fops1034,
              XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      super(
              issue,
              options: options
           )

      if issue.content.name == 'span' and issue.content['class'] == 'default-media-display'
        markup = ' ' + issue.content.inner_html
        msg = "#{issue.name}, #{issue.content.name} found #{issue.content.content}"
        issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
               issue,
               options: {
                    action: :replace_content,
                    markup: markup,
                    warning_message: msg
                  }
            )
        figure_elem = issue.content.xpath("./ancestor::*[local-name()='figure'][1]").first
        unless figure_elem.nil? or figure_elem['style'] != 'display:none'
          msg = "#{issue.name}, #{figure_elem.name} found #{figure_elem['style']}"
          issue.actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                 issue,
                 options: {
                      action_node: figure_elem,
                      attribute_name: "style",
                      warning_message: msg
                    }
              )
        end
=begin
        msg = "#{issue.name}, #{issue.content.name} found #{issue.content.content}"

        case issue.content.content
        when "WASPS"
          action = UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                 issue,
                 options: {
                      action: :replace_content,
                      markup: "WASPs",
                      warning_message: msg
                    }
              )
        else
          action = UMPTG::XML::Pipeline::Action.new(
                  issue,
                  options: {
                      info_message: msg
                    }
              )
        end
=end
      end
    end
  end
end
