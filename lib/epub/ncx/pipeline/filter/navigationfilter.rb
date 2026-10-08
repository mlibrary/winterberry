module UMPTG::EPUB::NCX::Pipeline::Filter

  class NavigationFilter < UMPTG::XML::Pipeline::Filter

=begin
    XPATH = <<-PCKXPATH
    //*[
    local-name() = 'navPoint' or local-name()='pageTarget'
    ]
    PCKXPATH
=end
    XPATH = <<-NCXXPATH
    //*[
    local-name() = 'navMap'
    or local-name()='navList'
    or local-name()='pageList'
    ]
    NCXXPATH

    def initialize(process, options: {})
      super(
              process,
              :epub_ncx_navigation,
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

      name = issue.name
      reference_node = issue.content  # <navList|navMap|pageList> element

      action = UMPTG::XML::Pipeline::Action.new(
               issue,
               options: {
                    info_message: "#{issue.name}, #{issue.content.name} found NCX navigation #{reference_node.name}"
                  }
           )
      issue.actions << action

      case reference_node.name
      when "navList"
      when "navMap"
      when "pageList"
      else
      end

=begin
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
=end
    end
  end
end
