module UMPTG::CSS::Pipeline
  #require_relative(File.join("pipeline", "actions"))
  #require_relative(File.join("pipeline", "filter"))

  class Processor < UMPTG::Object

    attr_accessor :logger, :name, :filters, :options

    def initialize(args = {})
      a = args.clone

      @logger = a.key?(:logger) ? a[:logger] : UMPTG::Logger.create(logger_fp: STDOUT)

      a[:options] = {} if a[:options].nil?

      if a[:filters].nil?
        a[:filters] = UMPTG::CSS.FILTERS
      else
        a[:filters] = a[:filters].merge(UMPTG::CSS.FILTERS)
      end

      m_filters = a[:filters]
      a[:filters] = {}

      a[:options].each do |k,v|
        next unless v

        cl = m_filters[k]
        #raise "undefined filter #{k}" if cl.nil?
        next if cl.nil?

        a[:filters][k] = cl.new(args)
      end
      #raise "No filters defined" if a[:filters].empty?

      super(a)

      @name = @properties[:name]
      @options = @properties[:options]
      @filters = @properties[:filters].values
    end

    def run(css_parser, args = {})
      a = args.clone()

      actions = []
      @filters.each do |f|
        a[:name] = f.name
        actions += f.run(css_parser, a)
      end

      # Return XML::ActionResult
      args[:actions] = actions
      args[:logger] = @logger
      return UMPTG::XML::Pipeline::Action.process_actions(args)
    end

    def process_action_results(args = {})
      action_results = args[:action_results]
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
