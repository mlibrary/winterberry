module UMPTG::EPUB::OEBPS::Pipeline
  rq_path = File.join(File.expand_path(File.dirname(__FILE__)), "filter", "*")
  Dir.glob(rq_path).each {|f| require_relative(f) }

  FILTERS = {
        epub_oebps_accessible: UMPTG::EPUB::OEBPS::Pipeline::Filter::AccessibleFilter,
        epub_oebps_accessmode: UMPTG::EPUB::OEBPS::Pipeline::Filter::AccessModeFilter,
        epub_oebps_accessfeature: UMPTG::EPUB::OEBPS::Pipeline::Filter::AccessFeatureFilter,
        epub_oebps_opf: UMPTG::EPUB::OEBPS::Pipeline::Filter::OPFFilter
      }

  def self.FILTERS
    return FILTERS
  end
end
