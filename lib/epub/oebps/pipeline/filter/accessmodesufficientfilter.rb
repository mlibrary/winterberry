module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class AccessModeSufficientFilter < AccessFilter

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

    def report(issues, options: {}, logger: nil)
      super(
            issues,
            options: options,
            logger: logger
          )
      llogger = logger || @logger

      AccessFilter.mode_report(
            issues,
            options: options,
            logger: (logger || @logger),
          )
    end
  end
end
