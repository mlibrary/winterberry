module UMPTG::EPUB::OEBPS
  require_relative File.join('pipeline', 'filter')

  def self.Processor(name:, filters: nil, options: {}, logger: nil)
    m_filters = filters.nil? ? UMPTG::EPUB::OEBPS::Pipeline.FILTERS : \
                  filters.merge(UMPTG::EPUB::OEBPS::Pipeline.FILTERS)

    return UMPTG::XML::Processor(
            name: name,
            filters: m_filters,
            options: options,
            logger: logger
          )
  end
end
