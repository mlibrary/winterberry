module UMPTG::XHTML::Pipeline::Filter

  class ListItemFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='li'
    ]
    SXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :xhtml_list_item
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # <li> element

      action_list = []

      if reference_node.name == 'li'
        list_node = reference_node.xpath("./ancestor::*[local-name()='ul' or local-name()='ol'][1]").first
        if list_node.nil?
          # No list parent. Convert this item to 'p'
          action_list << UMPTG::XML::Pipeline::Actions::RenameElementAction.new(
                  name: name,
                  reference_node: reference_node,
                  action_node: reference_node,
                  new_element_name: "p",
                  warning_message: \
                    "#{name}, #{reference_node.name} found list item with no list parent #{reference_node}"
              )

        end
      end
      return action_list
    end
  end
end
