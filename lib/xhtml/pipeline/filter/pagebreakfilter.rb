module UMPTG::XHTML::Pipeline::Filter

  class PageBreakFilter < UMPTG::XML::Pipeline::Filter

=begin
    XPATH = <<-SXPATH
    //*[
    @role="doc-pagebreak" or @epub:type="pagebreak"
    ]
    SXPATH
=end
    XPATH = <<-SXPATH
    //*[
    @role="doc-pagebreak"
    or @*[local-name()='type' and namespace-uri()='http://www.idpf.org/2007/ops' and string()='pagebreak']
    ] | //*[
    local-name()='a' and (
    starts-with(@id,'page_')
    or starts-with(@id,'P')
    or starts-with(@id,'p')
    )
    ] | //*[
    local-name()='span' and (
    starts-with(@id,'p')
    )
    ]
    SXPATH


    def initialize(process, options: {})
      super(
              process,
              :xhtml_pagebreak,
              XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      super(issue, options: options)

      action = nil
      case
      when (issue.content['role'] == 'doc-pagebreak')
        action =  UMPTG::Pipeline::Action.new(
            issue,
            options: {
                    info_message: "#{@name}, found pagebreak #{issue.content}"
                }
          )
      when issue.content['epub:type'] == 'pagebreak'
        action = UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
            issue,
            options: {
                    attribute_name: "role",
                    attribute_value: "doc-pagebreak",
                    warning_message: "#{@name}, found pagebreak #{issue.content}"
                }
          )
      end
      issue.actions << action unless action.nil?

      unless issue.content.name == 'span'
        issue.actions << UMPTG::XML::Pipeline::Actions::RenameElementAction.new(
            issue,
            options: {
                    new_element_name: "span",
                    warning_message: "#{@name}, found invalid pagebreak #{issue.content}"
                }
          )
      end

      aria_label = (issue.content['aria-label'] || "").strip
      aria_label = (issue.content['aria-labelledby'] || "").strip if aria_label.nil?
      if aria_label.nil?
        pg_ndx = issue.content['id'].rindex('_')
        if pg_ndx.nil?
          pg_no = issue.content['id'][1..-1]
        else
          pg_no = issue.content['id'][pg_ndx+1..-1]
        end

        issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
            issue,
            options: {
                    attribute_name: "aria-label",
                    attribute_value: "Page " + pg_no,
                    warning_message: "#{issue.name}, found invalid pagebreak missing aria-label or aria-labelledby #{issue.content}"
                }
          )

      else
        pg_no = aria_label
      end

      txt = (issue.content.text || "").strip
      if txt.empty?
        nxt = issue.content.next_element
        txt = (nxt.text || "").strip unless nxt.nil?
        unless txt.empty?
          issue.actions << UMPTG::Pipeline::Action.new(
              issue,
              options: {
                      warning_message: "#{@name}, found pagebreak content in next element #{nxt}"
                  }
            )
        end
      end

      if txt.empty?
        issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
            issue,
            options: {
                    action: :replace_content,
                    markup: "Page " + pg_no,
                    warning_message: "#{@name}, found invalid pagebreak content #{issue.content}"
                }
          )
      end
    end
  end
end
