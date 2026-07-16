module UMPTG::EPUB::XHTML::Pipeline::Filter

  class LangFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='html'
    and not(@xml:lang)
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :epub_xhtml_lang,
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

      raise "missing entry property" if options[:entry].nil?

      epub = options[:entry].files.epub
      lang_node = epub.rendition.metadata.dc.find(element_name: "language").first
      lang = (lang_node.nil? or lang_node.text.downcase == "en") ? "en-US" : lang_node.text

      issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
            issue,
             options: {
                attribute_name: "xml:lang",
                attribute_value: lang,
                warning_message: "#{issue.name}, missing attribute #{issue.content.name}/@xml:lang"
              }
        )
    end
  end
end
