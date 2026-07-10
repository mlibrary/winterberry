module UMPTG::EPUB::OEBPS::Pipeline
  rq_path = File.join(File.expand_path(File.dirname(__FILE__)), "filter", "*")
  Dir.glob(rq_path).each {|f| require_relative(f) }

  FFILTERS = {
        epub_oebps_conforms_to: UMPTG::EPUB::OEBPS::Pipeline::Filter::ConformsToFilter,
        epub_oebps_certified_by: UMPTG::EPUB::OEBPS::Pipeline::Filter::CertifiedByFilter,
        epub_oebps_certifier_credential: UMPTG::EPUB::OEBPS::Pipeline::Filter::CertifierCredentialFilter,
      }

  def self.FILTERS
    return FFILTERS
  end
end
