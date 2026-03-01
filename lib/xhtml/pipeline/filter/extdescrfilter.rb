module UMPTG::XHTML::Pipeline::Filter

  class ExtDescrFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='img' and @aria-details
    ]
    SXPATH

    def initialize(options: nil)
      super(
              name: :xhtml_extdescr,
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
      reference_node = issue.content  # <img> element

      if reference_node.name == 'img'
        aria_details = (reference_node["aria-details"] || "").strip
        unless aria_details.empty?
          action = UMPTG::XML::Pipeline::Action.new(
                   name: name,
                   reference_node: reference_node,
                   info_message: "#{name}, #{reference_node.name} found aria-details=\"#{aria_details}\""
               )
          issue.actions << action

          ext_descr_node = reference_node.document.at_css("[id='#{aria_details}']")
          if ext_descr_node.nil?
            action.add_error_msg("no extended description link found for ID #{aria_details}")
          elsif ext_descr_node.name == 'a'
            action.add_info_msg("extended description link found #{ext_descr_node}")
          else
            action.add_warning_msg("extended description link invalid #{ext_descr_node}")
            first_elem = ext_descr_node.first_element_child
            unless first_elem.nil? or first_elem.name != 'a'
              first_elem_id = first_elem['id'] || ""
              if first_elem_id.empty?
                issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                         name: name,
                         reference_node: first_elem,
                         attribute_name: "id",
                         attribute_value: aria_details
                     )
                issue.actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                         name: name,
                         reference_node: ext_descr_node,
                         attribute_name: "id"
                     )
              end
            end
          end
        end
      end
    end
  end
end
