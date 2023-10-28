module UMPTG::XML::Processor

  class Processor < UMPTG::Object

    attr_accessor :logger, :filters

    def initialize(args = {})
      super(args)

      @logger = @properties.key?(:logger) ? @properties[:logger] : UMPTG::Logger.create(logger_fp: STDOUT)
      @filters = @properties.key?(:filters) ? @properties[:filters] : []
    end

    def run(xml_doc, args = {})
      actions = []
      @filters.each do |filter|
        actions += filter.run(xml_doc, args)
      end

      # Return XML::ActionResult
      args[:actions] = actions
      return UMPTG::XML::Processor::Action.process_actions(args)
    end

    def filter(filter_name)
      f_list = @filters.select {|f| f.name == filter_name }
      return f_list.first
    end
  end
end
