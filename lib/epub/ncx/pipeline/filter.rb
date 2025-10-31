module UMPTG::EPUB::NCX::Pipeline
  rq_path = File.join(File.expand_path(File.dirname(__FILE__)), "filter", "*")
  Dir.glob(rq_path).each {|f| require_relative(f) }

  FILTERS = {
        epub_ncx_content: UMPTG::EPUB::NCX::Pipeline::Filter::ContentFilter,
        epub_ncx_navigation: UMPTG::EPUB::NCX::Pipeline::Filter::NavigationFilter,
      }

  def self.FILTERS
    return FILTERS
  end
end
