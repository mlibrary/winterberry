module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class AccessModeSufficientFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='metadata'
    ]/*[
    local-name()='meta' and @property='schema:accessModeSufficient'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :epub_oebps_accessmode_sufficient,
              XPATH,
              options: options
            )
    end
  end
end
