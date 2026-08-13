module UMPTG::EPUB::XHTML::Pipeline::Filter

  class DivisionRoleFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    (local-name()='article' or local-name()='section' or local-name()='p' or local-name()='a')
    and (@role or @epub:type)
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :epub_xhtml_divisionrole,
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
      if issue.content.name == "article"
        issue.actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                 issue,
                 options: {
                     attribute_name: "role",
                     warning_message: \
                       "#{name}, #{issue.content.name} found missing role=\"#{role}\""
                     }
             )
        issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
                 issue,
                 options: {
                     attribute_name: "epub:type",
                     attribute_value: "article",
                     warning_message: \
                       "#{name}, #{issue.content.name} missing role=\"article\""
                     }
             )
      else
        if role.empty? or role.downcase == "main"
          epub_type = (issue.content['epub:type'] || "").strip

          new_role = ""
          case epub_type.downcase
          when "backmatter", "bodymatter", "contributors", "copyright-page",\
              "division", "frontmatter", "halftitlepage", "index-group",\
              "index-locator", "note", "titlepage"
          else
            new_role = 'doc-' + epub_type
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
end
