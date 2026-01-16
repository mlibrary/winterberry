module UMPTG::Pipeline

  class Processor < UMPTG::Object

    attr_reader :name, :filters, :options
    attr_accessor :logger

    def initialize(name:, filters: nil, options: {}, logger: nil)
      @logger = logger.nil? ? UMPTG::Logger.create(logger_fp: STDOUT) : logger

      a = {
              name: name,
              logger: @logger,
              options: options
          }

      m_filters = filters.nil? ? UMPTG::Pipeline::FILTERS : \
              filters.merge(UMPTG::Pipeline::FILTERS)
      a[:filters] = {}
      options.each do |k,v|
        next unless v

        cl = m_filters[k]
        #raise "undefined filter #{k}" if cl.nil?
        next if cl.nil?

        a[:filters][k] = cl.new(
                      options: { logger: @logger }
                    )
      end
      #raise "No filters defined" if a[:filters].empty?

      super(a)

      @name = @properties[:name]
      @filters = @properties[:filters].values
      @options = @properties[:options]
    end

    def select(content, options: {})
      issues = []
      @filters.collect {|f| issues += f.select(content, options: options) }
      return issues
    end

    def review(issues, options: {})
      issues.each do |issue|
        @filters.each {|f| f.review(issue, options: options) }
      end
    end

    def process_results(results, options: {}, logger: nil)
      logger = @logger if logger.nil?
      @filters.each do |f|
        issues = results.issues.select {|i| i.name == f.name }
        f.process_results(issues, options: options, logger: logger)
      end
    end

    def run(content, options: {}, logger: nil)
      issues = select(content, options: options)
      review(issues, options: options)

      # Return XML::ActionResult
      results = UMPTG::Pipeline::Action.process_issues(
              issues,
              logger: logger.nil? ? @logger : logger,
              options: options
            )
      presults = options[:process_results] || true
      process_results(results, options: options, logger: @logger) if presults
      return results
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
