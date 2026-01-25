module UMPTG::EPUB::NCX::Pipeline::Filter

  class NavigationFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-PCKXPATH
    //*[
    local-name() = 'navPoint' or local-name()='pageTarget'
    ]
    PCKXPATH

    def initialize(options: nil)
      super(
              name: :epub_ncx_navigation,
              xpath: XPATH,
              options: options
            )
    end

    def resolve(issue, options: {})
      return unless issue.name == name

      super(
              issue,
              options: options
           )

      name = issue.name
      reference_node = issue.content  # <navPoint|pageTarget> element

      if reference_node.name == "navPoint" or reference_node.name == "pageTarget"
        id = reference_node["id"]
        id = id.nil? ? "" : id.strip
        if id.match?(/^[0-9]/)
          new_id = reference_node.name == "navPoint" ? "nav" + id : "page" + id
          issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                    name: name,
                    reference_node: reference_node,
                    attribute_name: "id",
                    attribute_value: new_id,
                    warning_message: "#{name}, invalid id value #{id}"
                  )
        end
      end
    end
  end
end
