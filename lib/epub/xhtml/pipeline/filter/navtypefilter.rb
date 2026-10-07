module UMPTG::EPUB::XHTML::Pipeline::Filter

  class NavTypeFilter < UMPTG::XML::Pipeline::Filter

=begin
    XPATH = <<-SXPATH
    //*[
    local-name()='nav'
    and (@role or @epub:type)
    ] | //*[
    local-name()='section'
    and (
    @role='doc-toc' or @epub:type='toc'
    or @epub:type='landmarks'
    or @epub:type='page-list'
    )
    ]
=end
    XPATH = <<-SXPATH
    //*[
    local-name()='nav'
    and (@role or @*[local-name()='type' and namespace-uri()='http://www.idpf.org/2007/ops'])
    ] | //*[
    local-name()='section'
    and (
    @role='doc-toc'
    or (
    @*[
    local-name()='type'
    and namespace-uri()='http://www.idpf.org/2007/ops'
    and (
    string()='toc'
    or string()='landmarks'
    or string()='page-list'
    )
    ]
    )
    )
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :epub_xhtml_navtype,
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
      epub_type = (issue.content['epub:type'] || "").strip

      action = UMPTG::XML::Pipeline::Action.new(
               issue
           )
      issue.actions << action

      msg = "#{issue.name}, #{issue.content.name} "
      case
      when (role.empty? and epub_type.empty?)
        action.add_warning_msg(msg + "found navigation with no @role or @epub:type values")
      when role.empty?
        action.add_warning_msg(msg + "found navigation with no @role value, @epub:type=#{epub_type}")
      when epub_type.empty?
        action.add_warning_msg(msg + "found navigation with @role=#{role}, no @epub:type value")
      else
        action.add_info_msg(msg + "found navigation with @role=#{role}, @epub:type=#{epub_type}")
      end
    end
  end
end
