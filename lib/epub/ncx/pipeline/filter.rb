module UMPTG::EPUB::NCX::Pipeline
  require_relative(File.join("filter", "testfilter"))

  FILTERS = {
        epub_ncx_test: UMPTG::EPUB::NCX::Pipeline::Filter::TestFilter,
      }

  def self.TestFilter(args = {})
    return FILTERS[:epub_ncx_test].new(args)
  end

  def self.FILTERS
    return FILTERS
  end
end
