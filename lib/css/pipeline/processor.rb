module UMPTG::CSS::Pipeline

  class Processor < UMPTG::Pipeline::Processor

    def initialize(name, filters: nil, options: {}, logger: nil)

      m_filters = filters.nil? ? UMPTG::CSS.FILTERS : \
              filters.merge(UMPTG::CSS.FILTERS)
      super(
            name,
            filters: m_filters,
            options: options,
            logger: logger
          )
    end
  end
end
