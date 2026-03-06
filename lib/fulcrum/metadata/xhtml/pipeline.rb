module UMPTG::Fulcrum::Metadata::XHTML
  require_relative(File.join("pipeline", "filter"))

  def self.Processor(name, filters: nil, options: {}, logger: nil)
    m_filters = filters.nil? ? UMPTG::Fulcrum::Metadata::XHTML::Pipeline.FILTERS : \
                  filters.merge(UMPTG::Fulcrum::Metadata::XHTML::Pipeline.FILTERS)

    return UMPTG::XHTML::Processor(
            name,
            filters: m_filters,
            options: options,
            logger: logger
          )
  end
end
