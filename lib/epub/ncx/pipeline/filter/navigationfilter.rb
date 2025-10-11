module UMPTG::EPUB::NCX::Pipeline::Filter

  class NavigationFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-PCKXPATH
    //*[
    local-name() = 'navPoint' or local-name()='pageTarget'
    ]
    PCKXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :epub_ncx_navigation
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      reference_node = args[:reference_node]

      actions = []

      if reference_node.name == "navPoint" or reference_node.name == "pageTarget"
        id = reference_node["id"]
        id = id.nil? ? "" : id.strip
        if id.match?(/^[0-9]/)
          new_id = reference_node.name == "navPoint" ? "nav" + id : "page" + id
          actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                    name: name,
                    reference_node: reference_node,
                    attribute_name: "id",
                    attribute_value: new_id,
                    warning_message: "#{name}, invalid id value #{id}"
                  )
        end
      end
      return actions
    end
  end
end
