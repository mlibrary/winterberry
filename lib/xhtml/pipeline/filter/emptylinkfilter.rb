module UMPTG::XHTML::Pipeline::Filter

  class EmptyLinkFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='a'
    and @href
    and normalize-space(string())=''
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_empty_link,
              XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      super(issue, options: options)

      issue.actions << UMPTG::XML::Pipeline::Actions::RemoveElementAction.new(
          issue,
          options: {
                  warning_message: "#{@name}, found invalid link target #{issue.content}"
              }
        )
    end
  end
end
