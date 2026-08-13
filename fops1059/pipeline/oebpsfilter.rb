module UMPTG::EPUB::OEBPS::Pipeline
  require_relative(File.join("filter", "CertifiedByFilter"))
  require_relative(File.join("filter", "CertifierCredentialFilter"))

  OEBPS_FILTERS = {
        epub_oebps_certified_by: UMPTG::EPUB::OEBPS::Pipeline::Filter::CertifiedByFilter,
        epub_oebps_certifier_credential: UMPTG::EPUB::OEBPS::Pipeline::Filter::CertifierCredentialFilter,
      }

  def self.FILTERS
    return OEBPS_FILTERS
  end
end
