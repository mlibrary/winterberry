module UMPTG::Fulcrum::Filter

  class ManifestFilter < UMPTG::XML::Pipeline::Filter
    attr_reader :manifest

    def initialize(args = {})
      super(args)

      @manifest = @properties[:manifest]
      raise "manifest must be specified" if @manifest.nil?
    end
  end
end
