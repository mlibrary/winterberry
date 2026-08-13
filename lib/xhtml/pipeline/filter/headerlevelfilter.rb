module UMPTG::XHTML::Pipeline::Filter

  class HeaderLevelFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='h4' or local-name()='h5' or local-name()='h6'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_header_level,
              XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      super(
              issue,
              options: options
           )

      prev_h = issue.content.xpath("./preceding-sibling::*[starts-with(local-name(),'h')]").first
      unless prev_h.nil?
        issue.actions << UMPTG::XML::Pipeline::Actions::RenameElementAction.new(
            issue,
            options: {
                    new_element_name: prev_h.name,
                    warning_message: "#{@name}, found invalid header level #{issue.content}"
                }
          )
      end
    end
  end
end
