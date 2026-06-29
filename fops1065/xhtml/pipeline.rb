module UMPTG::FOPS1065::XHTML
  require_relative(File.join("pipeline", "filter"))
  require_relative(File.join("pipeline", "processor"))

  def self.Processor(name, filters: nil, options: {}, logger: nil)
    m_filters = filters.nil? ? UMPTG::FOPS1065::XHTML::Pipeline.FILTERS : \
                  filters.merge(UMPTG::FOPS1065::XHTML::Pipeline.FILTERS)
    return Pipeline::Processor.new(
            name,
            filters: m_filters,
            options: options,
            logger: logger
          )
  end
end
