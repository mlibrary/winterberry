module UMPTG::EPUB::XHTML::Pipeline::Filter

  class LangFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='html'
    and (not(@xml:lang) or not(@lang))
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

      lang = (issue.content['lang'] || "").strip
      xml_lang = (issue.content['xml:lang'] || "").strip
      new_lang = lang.empty? ? xml_lang : lang
      if new_lang.empty?
        dc_lang_node = epub.rendition.metadata.dc.find(element_name: "language").first
        new_lang = (dc_lang_node.nil? or dc_lang_node.text.downcase == "en") ? "en-US" : dc_lang_node.text
      end
      if lang.empty?
        issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
              issue,
               options: {
                  attribute_name: "lang",
                  attribute_value: new_lang,
                  warning_message: "#{issue.name}, missing attribute #{issue.content.name}/@lang"
                }
          )
      end
      if xml_lang.empty?
        issue.actions << UMPTG::XML::Pipeline::Actions::SetAttributeValueAction.new(
              issue,
               options: {
                  attribute_name: "xml:lang",
                  attribute_value: new_lang,
                  warning_message: "#{issue.name}, missing attribute #{issue.content.name}/@xml:lang"
                }
          )
      end
    end
  end
end
