module UMPTG::EPUB::XHTML::Pipeline
  require_relative(File.join("filter", "testfilter"))

  FILTERS = {
        epub_xhtml_test: UMPTG::EPUB::XHTML::Pipeline::Filter::TestFilter,
      }

  def self.TestFilter(args = {})
    return FILTERS[:epub_xhtml_test].new(args)
  end

  def self.FILTERS
    return FILTERS
  end
end
