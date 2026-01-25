module UMPTG::XML::Pipeline

  class Processor < UMPTG::Pipeline::Processor

    attr_reader :xpath

    def initialize(name:, filters: nil, options: {}, logger: nil)

      m_filters = filters.nil? ? UMPTG::XML::Pipeline::FILTERS : \
              filters.merge(UMPTG::XML::Pipeline::FILTERS)
      super(
            name: name,
            filters: m_filters,
            options: options,
            logger: logger
          )

      @xpath = @filters.collect {|f| f.xpath }.join('|') || ""
    end

    def select(xml_doc, options: {})
      issues = []
      unless @xpath.empty?
        n_list = xml_doc.xpath(@xpath)

        f_node_list = {}
        @filters.each {|f| f_node_list[f.name] = f.select(xml_doc) }

        n_list.each do |n|
          f_node_list.each do |fn,fl|
            issues << UMPTG::Issue.new(name: fn, content: n) if fl.include?(n)
          end
        end
      end
      return issues
    end
  end
end
