module UMPTG::Journal::Resource

  class Processor < UMPTG::XML::Pipeline::Processor

    def initialize(args = {})
      manifest = args[:manifest]
      raise "manifest must be specified" if manifest.nil?

      args[:filters] = FILTERS
      super(args)
    end
  end
end
