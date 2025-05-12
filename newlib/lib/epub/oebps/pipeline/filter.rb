module UMPTG::EPUB::OEBPS::Pipeline
  require_relative(File.join("filter", "accessiblefilter"))

  FILTERS = {
        epub_oebps_accessible: UMPTG::EPUB::OEBPS::Pipeline::Filter::AccessibleFilter,
      }

  def self.AccessibleFilter(args = {})
    return FILTERS[:epub_oebps_accessible].new(args)
  end

  def self.FILTERS
    return FILTERS
  end
end
