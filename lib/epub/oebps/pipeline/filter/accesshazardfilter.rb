module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class AccessHazardFilter < AccessFilter

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

    def report(issues, options: {}, logger: nil)
      super(
            issues,
            options: options,
            logger: logger
          )

      features = {
            "flashing" => false,
            "motionSimulation" => false,
            "sound" => false,
            "none" => false,
            "noFlashingHazard" => false,
            "noMotionSimulationHazard" => false,
            "noSoundHazard" => false,
            "unknown" => false,
            "unknownFlashingHazard" => false,
            "unknownMotionSimulationHazard" => false,
            "unknownSoundHazard" => false,
         }
      AccessFilter.report(
            issues,
            features,
            options: options,
            logger: (logger || @logger),
          )
    end
  end
end
