module UMPTG::Journal::Resource

  class Processor < UMPTG::XML::Pipeline::Processor

    attr_accessor :manifest, :resource_map

    def initialize(name, manifest: nil, resource_map: nil, filters: nil, options: {}, logger: nil)
      m_filters = filters.nil? ? UMPTG::Journal::Resource::FILTERS : \
              filters.merge(UMPTG::Journal::Resource::FILTERS)

    puts "manifest=#{manifest.nil?},m_filters=#{m_filters.nil?}"
      super(
            name,
            filters: m_filters,
            options: options,
            logger: logger
          )
      @manifest = manifest
      @resource_map = resource_map
    end
  end
end
