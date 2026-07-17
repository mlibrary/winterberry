module UMPTG::EPUB::XHTML
  require_relative File.join('pipeline', 'filter')

  def self.Processor(name, filters: nil, options: {}, logger: nil)
    m_filters = filters.nil? ? UMPTG::EPUB::XHTML::Pipeline.FILTERS : \
                  filters.merge(UMPTG::EPUB::XHTML::Pipeline.FILTERS)

    return UMPTG::XHTML.Processor(
            name,
            filters: m_filters,
            options: options,
            logger: logger
          )
  end
end
