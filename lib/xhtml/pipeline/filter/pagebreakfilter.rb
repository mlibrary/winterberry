module UMPTG::XHTML::Pipeline::Filter

  class PageBreakFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    @role="doc-pagebreak"
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_pagebreak,
              XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      super(issue, options: options)

      id = issue.content['id'] || ""
      act = UMPTG::Pipeline::Action.new(
            issue,
            options: options
          )
      act.add_info_msg("#{@name}, found pagebreak id=\"#{id}\"")
      issue.actions << act
    end
  end
end
