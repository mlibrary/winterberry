module UMPTG::XML::Pipeline

  class Processor < UMPTG::Object

    attr_accessor :logger, :filters, :name, :options, :xpath

    def initialize(args = {})
      a = args.clone

      @logger = a.key?(:logger) ? a[:logger] : UMPTG::Logger.create(logger_fp: STDOUT)
      @options = a.key?(:options) ? a[:options] : {}

      if a[:filters].nil?
        a[:filters] = FILTERS
        a[:options][:xml_default] = false
      else
        a[:filters] = a[:filters].merge(FILTERS)
      end

      m_filters = a[:filters]
      a[:filters] = {}
      @options.each do |k,v|
        next unless v

        cl = m_filters[k]
        #raise "undefined filter #{k}" if cl.nil?
        next if cl.nil?

        a[:filters][k] = cl.new(args)
      end
      #raise "No filters defined" if a[:filters].empty?

      super(a)

      @name = @properties[:name]
      @filters = @properties[:filters].values
      @xpath = @filters.collect {|f| f.xpath }.join('|') || ""
    end

    def run(xml_doc, args = {})
      actions = []

      unless @xpath.empty?
        a = args.clone()
        a[:name] = @name
        xml_doc.xpath(@xpath).each do |n|
          a[:reference_node] = n
          @filters.each do |f|
            a[:name] = f.name
            actions += f.create_actions(a)
          end
        end
      end

      # Return XML::ActionResult
      args[:actions] = actions
      args[:logger] = @logger
      return UMPTG::XML::Pipeline::Action.process_actions(args)
    end

    def report_action_results(args = {})
      action_results = args[:action_results]

      a = args.clone
      @filters.each do |f|
        actions = []
        action_results.each {|ar| actions += ar.actions.select {|a| a.name == f.name } }

        a[:actions] = actions
        f.report_action_results(a)
      end

=begin
      action_results = args[:action_results]
      llogger = args[:logger] || @logger

      actions = []
      action_results.each {|ar| actions += ar.actions }
      UMPTG::XML::Pipeline::Action.process_actions(
            actions: actions,
            normalize: false,
            logger: llogger
          )
=end
    end

    def filter(filter_name)
      f_list = @filters.select {|f| f.name == filter_name }
      return f_list.first
    end

    def display_options()
      @options.each {|o,v| @logger.info("#{o}:#{v}") if @properties[:filters].key?(o) }
    end
  end
end
