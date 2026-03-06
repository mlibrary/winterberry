module UMPTG::Fulcrum::Filter

  class ManifestFilter < UMPTG::XML::Pipeline::Filter
    attr_reader :manifest

    def initialize(process, name, manifest, xpath, options: {})
      super(
            process,
            name,
            xpath,
            options: options
          )

      @manifest = manifest
      raise "manifest must be specified" if @manifest.nil?
    end
  end
end
