module UMPTG::Fulcrum::Filter

  class ManifestFilter < UMPTG::XML::Pipeline::Filter
    attr_reader :manifest

    def initialize(name:, manifest:, xpath:, options: {})
      super(
            name: name,
            xpath: xpath,
            options: options
          )

      @manifest = manifest
      raise "manifest must be specified" if @manifest.nil?
    end
  end
end
