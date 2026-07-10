module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class CertifiedByFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='metadata'
    and not(*[local-name()='meta' and @property='a11y:certifiedBy' and @id='certifier'])
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :epub_oebps_certified_by,
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

      markup = "<meta refines=\"#conf\" property=\"a11y:certifiedBy\" id=\"certifier\">Benetech</meta>"
      issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
            issue,
             options: {
                action: :add_child,
                markup: markup,
                warning_message: "#{issue.name}, missing #{issue.content.name}/meta/@property='a11y:certifiedBy'"
              }
        )
=begin
      issue.actions << UMPTG::XML::Pipeline::Action.new(
             issue,
             options: {
                info_message: "#{issue.name}, missing #{issue.content.name}/meta/@property='dcterms:conformsTo'"
              }
         )
=end
    end
  end
end
