module UMPTG::XHTML::Pipeline::Filter

  class ExtDescrFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='img' and @aria-details
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_extdescr,
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

      if issue.content.name == 'img'
        aria_details = (issue.content["aria-details"] || "").strip
        unless aria_details.empty?
          action = UMPTG::XML::Pipeline::Action.new(
                   name: issue.name,
                   reference_node: issue.content,
                   info_message: "#{issue.name}, #{issue.content.name} found aria-details=\"#{aria_details}\""
               )
          issue.actions << action

          ext_descr_node = issue.content.document.at_css("[id='#{aria_details}']")
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
                         name: issue.name,
                         reference_node: first_elem,
                         attribute_name: "id",
                         attribute_value: aria_details
                     )
                issue.actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                         name: issue.name,
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
