module UMPTG::XHTML::Pipeline

  class Processor < UMPTG::XML::Pipeline::Processor

    def initialize(name:, filters: nil, options: {}, logger: nil)

      m_filters = filters.nil? ? UMPTG::XHTML::Pipeline.FILTERS : \
                    filters.merge(UMPTG::XHTML::Pipeline.FILTERS)
      super(
            name: name,
            filters: m_filters,
            options: options,
            logger: logger
          )
    end
  end
end
