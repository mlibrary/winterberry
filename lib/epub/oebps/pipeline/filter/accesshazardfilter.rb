module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class AccessHazardFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='metadata'
    ]/*[
    local-name()='meta' and @property='schema:accessibilityHazard'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :epub_oebps_access_hazard,
              XPATH,
              options: options
            )
    end
  end
end
