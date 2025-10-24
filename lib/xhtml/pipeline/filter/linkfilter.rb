module UMPTG::XHTML::Pipeline::Filter

  class LinkFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='a'
    ]
    SXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :xhtml_link
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # <a> element

      action_list = []

      if reference_node.name == 'a'
        id = reference_node['id'] || ""
        href = (reference_node['href'] || "").strip
        action = UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: reference_node
              )
        if href.include?(' ') or href.include?('%20')
          href_new = href.gsub(/ /, '').gsub(/%20/, '')
          action = UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                  name: name,
                  reference_node: reference_node,
                  attribute_name: "href",
                  attribute_value: href_new,
                  warning_message: \
                    "#{name}, #{reference_node.name} found @id=\"#{id}\" @href=\"#{href}\", @href contains spaces"
              )
        else
          action.add_info_msg("#{name}, #{reference_node.name} found @id=\"#{id}\" @href=\"#{href}\"")
        end
        action_list << action
      end
      return action_list
    end
  end
end
