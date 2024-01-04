module UMPTG::XML::Pipeline

  class Processor < UMPTG::Object

    attr_accessor :logger, :filters, :options

    def initialize(args = {})
      super(args)

      @logger = @properties.key?(:logger) ? @properties[:logger] : UMPTG::Logger.create(logger_fp: STDOUT)
      @options = @properties.key?(:options) ? @properties[:options] : {}

      m_filters = @properties.key?(:filters) ? @properties[:filters] : []
      m_filters = m_filters.select {|key,proc| @options[key] == true }
      @filters = m_filters.values
    end

    def run(xml_doc, args = {})
      actions = []
      @filters.each do |filter|
        actions += filter.run(xml_doc, args)
      end

      # Return XML::ActionResult
      args[:actions] = actions
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
