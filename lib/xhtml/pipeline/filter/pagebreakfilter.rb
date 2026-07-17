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
  end
end
