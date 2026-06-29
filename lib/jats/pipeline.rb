module UMPTG::JATS
  require_relative(File.join("pipeline", "filter"))

  def self.Processor(name, filters: nil, options: {}, logger: nil)
    m_filters = filters.nil? ? UMPTG::JATS::Pipeline.FILTERS : \
                  filters.merge(UMPTG::JATS::Pipeline.FILTERS)
    return UMPTG::XML::Pipeline::Processor.new(
            name,
            filters: m_filters,
            options: options,
            logger: logger
        )
  end
end
