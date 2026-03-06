module UMPTG::XHTML::Pipeline::Filter

  class ListItemFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='li'
    ]
    SXPATH

    def initialize(options: nil)
      super(
              :xhtml_list_item,
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

      if issue.content.name == 'li'
        list_node = issue.content.xpath("./ancestor::*[local-name()='ul' or local-name()='ol'][1]").first
        if list_node.nil?
          # No list parent. Convert this item to 'p'
          issue.actions << UMPTG::XML::Pipeline::Actions::RenameElementAction.new(
                  name: issue.name,
                  reference_node: issue.content,
                  action_node: issue.content,
                  new_element_name: "p",
                  warning_message: \
                    "#{issue.name}, #{issue.content.name} found list item with no list parent #{issue.content}"
              )

        end
      end
    end
  end
end
