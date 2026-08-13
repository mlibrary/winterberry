module UMPTG::XHTML::Pipeline::Filter

  class EmptyHeaderFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    (local-name()='h1' or local-name()='h2' or local-name()='h3' or local-name()='h4' or local-name()='th')
    and normalize-space(string())=''
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_empty_header,
              XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      super(
              issue,
              options: options
           )

      id = (issue.content['id'] || "")
      if id.empty?
        issue.actions << UMPTG::XML::Pipeline::Actions::RemoveElementAction.new(
                 issue,
                 options: {
                    warning_message: "#{name}: empty header #{issue.content.name}"
                  }
             )
      end
    end
  end
end
