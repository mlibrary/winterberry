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
        href = reference_node['href'] || ""
        action_list << UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: reference_node,
                 info_message: \
                   "#{name}, #{reference_node.name} found @id=\"#{id}\" @href=\"#{href}\""
             )
      end
      return action_list
    end
  end
end
