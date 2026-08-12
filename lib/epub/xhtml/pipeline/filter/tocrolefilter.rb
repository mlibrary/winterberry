module UMPTG::EPUB::XHTML::Pipeline::Filter

  class TOCRoleFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='nav'
    and (@role or @epub:type)
    ] | //*[
    local-name()='section'
    and (@role='doc-toc' or @epub:type='toc')
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :epub_xhtml_tocrole,
              XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      super(
              issue,
              options: options
           )

      role = (issue.content['role'] || "").strip
      if role.empty?
        epub_type = (issue.content['epub:type'] || "").strip

        new_role = ''
        case epub_type.downcase
        when "landmarks"
          issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                   issue,
                   options: {
                       attribute_name: "aria-label",
                       attribute_value: "Guide",
                       warning_message: \
                         "#{name}, #{issue.content.name} missing aria-label for #{epub_type}"
                       }
               )
        when "toc"
          new_role = "doc-toc"
        when "page-list"
          new_role = "doc-pagelist"
        else
          # epub:type is empty
          issue.actions << UMPTG::XML::Pipeline::Action.new(
                   issue,
                   options: {
                       warning_message: \
                         "#{issue.name}, #{issue.content.name} found navigation with no @role or @epub:type values"
                       }
               )
        end

        unless new_role.empty?
          issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                   issue,
                   options: {
                       attribute_name: "role",
                       attribute_value: new_role,
                       warning_message: \
                         "#{name}, #{issue.content.name} missing role=\"#{new_role}\""
                       }
               )
        end
      end
    end
  end
end
