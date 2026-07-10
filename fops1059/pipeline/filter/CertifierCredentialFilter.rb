module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class CertifierCredentialFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='metadata'
    and not(*[local-name()='meta' and @property='a11y:certifierCredential' and @id='certifierCredential'])
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :epub_oebps_certifier_credential,
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

      markup = "<meta refines=\"#certifier\" property=\"a11y:certifierCredential\">https://bornaccessible.org/certification/gca-credential/</meta>"
      issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
            issue,
             options: {
                action: :add_child,
                markup: markup,
                warning_message: "#{issue.name}, missing #{issue.content.name}/meta/@property='a11y:certifierCredential'"
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
