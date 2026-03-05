module UMPTG::EPUB::OEBPS
  require_relative File.join('pipeline', 'filter')
  require_relative File.join('pipeline', 'processor')

  def self.Processor(name, filters: nil, options: {}, logger: nil)
    m_filters = filters.nil? ? UMPTG::EPUB::OEBPS::Pipeline.FILTERS : \
                  filters.merge(UMPTG::EPUB::OEBPS::Pipeline.FILTERS)

    return UMPTG::EPUB::OEBPS::Pipeline::Processor.new(
            name,
            filters: m_filters,
            options: options,
            logger: logger
          )
  end
end
