module UMPTG::XHTML::Pipeline::Filter

  class PageBreakFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    @role="doc-pagebreak" or @epub:type="pagebreak"
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

      case
      when (issue.content['role'] == 'doc-pagebreak' and issue.content['epub:type'] == 'pagebreak')
        issue.actions << UMPTG::Pipeline::Action.new(
            issue,
            options: {
                    info_message: "#{@name}, found pagebreak #{issue.content}"
                }
          )
      when issue.content['epub:type'] == 'pagebreak'
        issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
            issue,
            options: {
                    attribute_name: "role",
                    attribute_value: "doc-pagebreak",
                    warning_message: "#{@name}, found pagebreak #{issue.content}"
                }
          )
      end

      unless issue.content.name == 'span'
        issue.actions << UMPTG::XML::Pipeline::Actions::RenameElementAction.new(
            issue,
            options: {
                    new_element_name: "span",
                    warning_message: "#{@name}, found invalid pagebreak #{issue.content}"
                }
          )
      end

      pg_ndx = issue.content['id'].rindex('_')
      pg_no = issue.content['id'][pg_ndx+1..-1]

      issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
          issue,
          options: {
                  attribute_name: "aria-label",
                  attribute_value: "Page " + pg_no,
                  warning_message: "#{@name}, found invalid pagebreak #{issue.content}"
              }
        )
=begin
      # Moved to Reviewer.review()
      issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
          issue,
          options: {
                  attribute_name: "class",
                  attribute_value: "page",
                  attribute_append: true,
                  warning_message: "#{@name}, found invalid pagebreak class attribute #{issue.content}"
              }
        )
=end
      if issue.content.text.empty?
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
