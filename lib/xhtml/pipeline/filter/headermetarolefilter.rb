module UMPTG::XHTML::Pipeline::Filter

  class HeaderMetaRoleFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='head'
    ]/*[
    local-name()='meta' and @role
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_header_meta_role,
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

      if issue.content.name == 'meta'
        role = issue.content['role']
        unless role.nil?
          issue.actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                    name: issue.name,
                    reference_node: issue.content,
                    attribute_name: "role",
                    warning_message: "#{issue.name}, #{issue.content.name}/@role=\"#{role}\" not allowed"
                  )
        end
      end
    end
  end
end
