module UMPTG::EPUB::OEBPS::Pipeline
  rq_path = File.join(File.expand_path(File.dirname(__FILE__)), "filter")
  require_relative(File.join(rq_path, "accessfilter"))
  Dir.glob(File.join(rq_path, "*")).each {|f| require_relative(f) }

  FILTERS = {
        epub_oebps_accessible: UMPTG::EPUB::OEBPS::Pipeline::Filter::AccessibleFilter,
        epub_oebps_accessmode: UMPTG::EPUB::OEBPS::Pipeline::Filter::AccessModeFilter,
        epub_oebps_accessmode_sufficient: UMPTG::EPUB::OEBPS::Pipeline::Filter::AccessModeSufficientFilter,
        epub_oebps_accessfeature: UMPTG::EPUB::OEBPS::Pipeline::Filter::AccessFeatureFilter,
        epub_oebps_access_summary: UMPTG::EPUB::OEBPS::Pipeline::Filter::AccessSummaryFilter,
        epub_oebps_conforms_to: UMPTG::EPUB::OEBPS::Pipeline::Filter::ConformsToFilter,
        epub_oebps_access_hazard: UMPTG::EPUB::OEBPS::Pipeline::Filter::AccessHazardFilter,
        epub_oebps_lang: UMPTG::EPUB::OEBPS::Pipeline::Filter::LangFilter,
        epub_oebps_opf: UMPTG::EPUB::OEBPS::Pipeline::Filter::OPFFilter
      }

  def self.FILTERS
    return FILTERS
  end
end
