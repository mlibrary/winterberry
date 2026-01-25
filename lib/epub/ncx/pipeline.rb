module UMPTG::EPUB::NCX
  require_relative File.join('pipeline', 'filter')

  def self.Processor(name:, filters: nil, options: {}, logger: nil)
    m_filters = filters.nil? ? UMPTG::EPUB::NCX::Pipeline.FILTERS : \
                  filters.merge(UMPTG::EPUB::NCX::Pipeline.FILTERS)

    return UMPTG::XML::Processor(
            name: name,
            filters: m_filters,
            options: options,
            logger: logger
          )
  end
end
