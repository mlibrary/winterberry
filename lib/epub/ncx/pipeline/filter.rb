module UMPTG::EPUB::NCX::Pipeline
  require_relative(File.join("filter", "contentfilter"))
  require_relative(File.join("filter", "navigationfilter"))

  FILTERS = {
        epub_ncx_content: UMPTG::EPUB::NCX::Pipeline::Filter::ContentFilter,
        epub_ncx_navigation: UMPTG::EPUB::NCX::Pipeline::Filter::NavigationFilter,
      }

  def self.ContentFilter(args = {})
    return FILTERS[:epub_ncx_content].new(args)
  end

  def self.NavigationFilter(args = {})
    return FILTERS[:epub_ncx_navigation].new(args)
  end

  def self.FILTERS
    return FILTERS
  end
end
