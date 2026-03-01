module UMPTG::XHTML::Pipeline::Filter

  class ListItemFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='li'
    ]
    SXPATH

    def initialize(options: nil)
      super(
              name: :xhtml_list_item,
              xpath: XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      return unless issue.name == name

      super(
              issue,
              options: options
           )

      name = issue.name
      reference_node = issue.content  # <li> element

      if reference_node.name == 'li'
        list_node = reference_node.xpath("./ancestor::*[local-name()='ul' or local-name()='ol'][1]").first
        if list_node.nil?
          # No list parent. Convert this item to 'p'
          issue.actions << UMPTG::XML::Pipeline::Actions::RenameElementAction.new(
                  name: name,
                  reference_node: reference_node,
                  action_node: reference_node,
                  new_element_name: "p",
                  warning_message: \
                    "#{name}, #{reference_node.name} found list item with no list parent #{reference_node}"
              )

        end
      end
    end
  end
end
