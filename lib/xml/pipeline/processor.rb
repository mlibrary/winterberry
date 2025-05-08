module UMPTG::XML::Pipeline

  class Processor < UMPTG::Object

    attr_accessor :logger, :filters, :options, :xpath

    def initialize(args = {})
      a = args.clone

      @logger = a.key?(:logger) ? a[:logger] : UMPTG::Logger.create(logger_fp: STDOUT)
      @options = a.key?(:options) ? a[:options] : {}

      m_filters = a.key?(:filters) ? a[:filters] : []
      a[:filters] = {}
      @options.each do |k,v|
        next unless v

        cl = m_filters[k]
        raise "undefined filter #{k}" if cl.nil?

        a[:filters][k] = cl.new(args)
      end
      raise "No filters defined" if a[:filters].empty?

      super(a)

      @filters = @properties[:filters].values
      @xpath = @filters.collect {|f| f.xpath }.join('|')
    end

    def run(xml_doc, args = {})
      actions = []

      a = args.clone()
      a[:name] = @name
      xml_doc.xpath(@xpath).each do |n|
        a[:reference_node] = n
        @filters.each do |f|
          a[:name] = f.name
          actions += f.create_actions(a)
        end
      end

      # Return XML::ActionResult
      args[:actions] = actions
      args[:logger] = @logger
      return UMPTG::XML::Pipeline::Action.process_actions(args)
    end

    def filter(filter_name)
      f_list = @filters.select {|f| f.name == filter_name }
      return f_list.first
    end

    def display_options()
      @options.each {|o,v| @logger.info("#{o}:#{v}") }
    end
  end
end
