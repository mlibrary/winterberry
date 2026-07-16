module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class ConformsToFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='metadata'
    and not(*[local-name()='meta' and @property='dcterms:conformsTo' and @id='conf'])
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :epub_oebps_conforms_to,
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

      markup = "<meta property=\"dcterms:conformsTo\" id=\"conf\">EPUB Accessibility 1.1 - WCAG 2.2 Level AA</meta>"
      issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
            issue,
             options: {
                action: :add_child,
                markup: markup,
                warning_message: "#{issue.name}, missing #{issue.content.name}/meta/@property='dcterms:conformsTo'"
              }
        )
    end
  end
end
