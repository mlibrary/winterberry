module UMPTG::Journal::Resource

  class Processor < UMPTG::XML::Pipeline::Processor

    def initialize(args = {})
      manifest = args[:manifest]
      resource_map = args[:resource_map]
      logger = args[:logger]

      raise "manifest must be specified" if manifest.nil?

      resource_filter = Filter::ResourceFilter.new(
                    manifest: manifest,
                    resource_map: resource_map,
                    logger: logger
                  )
      args[:filters] = {
              resource: resource_filter
            }
      super(args)
    end
  end
end
