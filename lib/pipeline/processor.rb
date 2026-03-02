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

      filter_options = { logger: @logger }
      filter_options[:manifest] = options[:manifest] if options.key?(:manifest)
      m_filters = filters.nil? ? UMPTG::Pipeline::FILTERS : \
              filters.merge(UMPTG::Pipeline::FILTERS)
      a[:filters] = {}
      options.each do |k,v|
        next if k == :manifest
        next unless v

        cl = m_filters[k]
        #raise "undefined filter #{k}" if cl.nil?
        next if cl.nil?

        a[:filters][k] = cl.new(
                      options: filter_options
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

    def resolve(issues, options: {}, logger: nil)
      logger = @logger if logger.nil?

      # Return XML::ActionResult
      return UMPTG::Pipeline::Action.resolve_issues(
              issues,
              logger: logger,
              options: options
            )
    end

    def report_issues(issues, options: {}, logger: nil)
      process_results = options.key?(:process_results) ? options[:process_results] : false

      if process_results
        logger = @logger if logger.nil?

        @filters.each do |f|
          ss = issues.select {|i| i.name == f.name }
          f.report(ss, options: options, logger: logger)
        end
      end
    end

    def report(result, options: {}, logger: nil)
      report_issues(result.issues, options: options, logger: logger)
    end

    def run(content, options: {}, logger: nil)
      logger = @logger if logger.nil?

      issues = select(content, options: options)
      review(issues, options: options)

      result = resolve(issues, options: options, logger: logger)

      # Report the issue resolutions
      report(result, options: options, logger: logger)
      return result
    end

    def filter(filter_name)
      f_list = @filters.select {|f| f.name == filter_name }
      return f_list.first
    end

    def display_options()
      c = 0
      @options.each do |o,v|
        if @properties[:filters].key?(o)
          @logger.info("#{o}:#{v}")
          c += 1 if v
        end
      end
      @logger.warn("#{name}, no filters active") if c == 0
    end
  end
end
