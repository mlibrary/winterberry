module UMPTG::EPUB::OEBPS::Pipeline
  require_relative(File.join("filter", "accessiblefilter"))
  require_relative(File.join("filter", "accessmodefilter"))
  require_relative(File.join("filter", "accessfeaturefilter"))
  require_relative(File.join("filter", "opffilter"))

  FILTERS = {
        epub_oebps_accessible: UMPTG::EPUB::OEBPS::Pipeline::Filter::AccessibleFilter,
        epub_oebps_accessmode: UMPTG::EPUB::OEBPS::Pipeline::Filter::AccessModeFilter,
        epub_oebps_accessfeature: UMPTG::EPUB::OEBPS::Pipeline::Filter::AccessFeatureFilter,
        epub_oebps_opf: UMPTG::EPUB::OEBPS::Pipeline::Filter::OPFFilter
      }

  def self.AccessibleFilter(args = {})
    return FILTERS[:epub_oebps_accessible].new(args)
  end

  def self.AccessModeFilter(args = {})
    return FILTERS[:epub_oebps_accessmode].new(args)
  end

  def self.AccessFeatureFilter(args = {})
    return FILTERS[:epub_oebps_accessfeature].new(args)
  end

  def self.OPFFilter(args = {})
    return FILTERS[:epub_oebps_opf].new(args)
  end

  def self.FILTERS
    return FILTERS
  end
end
