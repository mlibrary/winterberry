module UMPTG::XHTML::Pipeline
  require_relative(File.join("filter", "HTMLLangFilter"))

  XHTML_FILTERS = {
        epub_xhtml_lang: UMPTG::XHTML::Pipeline::Filter::HTMLLangFilter,
      }

  def self.FILTERS
    return XHTML_FILTERS
  end
end
