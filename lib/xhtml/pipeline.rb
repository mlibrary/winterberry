module UMPTG::XHTML
  require_relative(File.join("pipeline", "actions"))
  require_relative(File.join("pipeline", "filter"))

  def self.Processor(name:, filters: nil, options: {}, logger: nil)
    m_filters = filters.nil? ? UMPTG::XHTML::Pipeline.FILTERS : \
                  filters.merge(UMPTG::XHTML::Pipeline.FILTERS)

    return UMPTG::XML::Processor(
            name: name,
            filters: m_filters,
            options: options,
            logger: logger
          )
  end
end
