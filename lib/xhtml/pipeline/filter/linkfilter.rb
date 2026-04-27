module UMPTG::XHTML::Pipeline::Filter

  class LinkFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='a'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_link,
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

      if issue.content.name == 'a'
        id = issue.content['id'] || ""
        href = (issue.content['href'] || "").strip
        action = UMPTG::XML::Pipeline::Action.new(
                 name: issue.name,
                 reference_node: issue.content
              )
        if href.include?(' ') or href.include?('%20')
          href_new = href.gsub(/ /, '').gsub(/%20/, '')
=begin
          action = UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                  name: issue.name,
                  reference_node: issue.content,
                  attribute_name: "href",
                  attribute_value: href_new,
                  warning_message: \
                    "#{issue.name}, #{issue.content.name} found @id=\"#{id}\" @href=\"#{href}\", @href contains spaces"
              )
=end
          action = UMPTG::XML::Pipeline::Action.new(
                  name: issue.name,
                  reference_node: issue.content,
                  warning_message: \
                    "#{issue.name}, #{issue.content.name} found @id=\"#{id}\" @href=\"#{href}\", @href contains spaces"
              )
        else
          action.add_info_msg("#{issue.name}, #{issue.content.name} found @id=\"#{id}\" @href=\"#{href}\"")
        end
        issue.actions << action
      end
    end
  end
end
