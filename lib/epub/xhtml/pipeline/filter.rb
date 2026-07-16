module UMPTG::EPUB::XHTML::Pipeline
  rq_path = File.join(File.expand_path(File.dirname(__FILE__)), "filter", "*")
  Dir.glob(rq_path).each {|f| require_relative(f) }
  #require_relative(File.join("filter", "langfilter"))

  XHTML_FILTERS = {
        epub_xhtml_lang: UMPTG::EPUB::XHTML::Pipeline::Filter::LangFilter,
      }

  def self.FILTERS
    return XHTML_FILTERS
  end
end
