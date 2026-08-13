module UMPTG::EPUB::XHTML::Pipeline
  rq_path = File.join(File.expand_path(File.dirname(__FILE__)), "filter", "*")
  Dir.glob(rq_path).each {|f| require_relative(f) }
  #require_relative(File.join("filter", "langfilter"))

  XHTML_FILTERS = {
        epub_xhtml_lang: UMPTG::EPUB::XHTML::Pipeline::Filter::LangFilter,
        epub_xhtml_divisionrole: UMPTG::EPUB::XHTML::Pipeline::Filter::DivisionRoleFilter,
        epub_xhtml_tocrole: UMPTG::EPUB::XHTML::Pipeline::Filter::TOCRoleFilter,
      }

  def self.FILTERS
    return XHTML_FILTERS
  end
end
