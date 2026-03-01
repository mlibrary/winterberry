module UMPTG::EPUB::Pipeline

  class Processor < UMPTG::Object
    attr_reader :name, :processors
    attr_accessor :logger

    def initialize(name:, filters: nil, options: {}, logger: nil)
      a = {
              name: name || "EPUBProcessor",
              filters: filters,
              options: options,
              logger: logger
          }


      a[:css_processor] = UMPTG::CSS::Processor(name: "CSSProcessor", options: options, logger: logger) \
                 if options[:css_processor].nil?
      a[:ncx_processor] = UMPTG::EPUB::NCX::Processor(name: "NCXProcessor", options: options, logger: logger) \
                 if options[:ncx_processor].nil?
      a[:oebps_processor] = UMPTG::EPUB::OEBPS::Processor(name: "OEBPSProcessor", options: options, logger: logger) \
                 if options[:oebps_processor].nil?
      a[:xhtml_processor] = UMPTG::XHTML::Processor(name: "XHTMLProcessor", options: options, logger: logger) \
                 if options[:xhtml_processor].nil?
      a[:xml_processor] = UMPTG::XML::Processor(name: "XMLProcessor", options: options, logger: logger) \
                 if options[:xml_processor].nil?

      super(a)

      @name = @properties[:name]
      @logger = @properties.key?(:logger) ? @properties[:logger] : UMPTG::Logger.create(logger_fp: STDOUT)

      @processors = {
                "text/css" => @properties[:css_processor],
                "application/x-dtbncx+xml" => @properties[:ncx_processor],
                "application/oebps-package+xml" => @properties[:oebps_processor],
                "application/xhtml+xml" => @properties[:xhtml_processor],
                #"text/html" => @properties[:xhtml_processor],
                "text/xml" => @properties[:xml_processor]
            }
    end

    def run(epub, args = {})
      save_forced = args[:save_forced]
      @logger.info("Force save:#{save_forced}") unless save_forced.nil?

      # Indicate the options selected for this run.
      @processors.values.each do |processor|
        processor.logger = @logger
        processor.display_options()
        processor.logger = nil
      end

      epub_title =
      entry_actions = []

      run_args = args.clone
      run_args[:process_results] = false
      ([epub.rendition.entry] + epub.rendition.manifest.entries).each do |entry|
        media_type = entry.media_type.to_s
        processor = @processors[media_type]
        if processor.nil?
          @logger.warn("#{entry.name}, no processor for media type #{media_type}")
          next
        end

        case media_type
        when "text/css"
          r_args = args.clone
          r_args[:process_results] = false
          result = processor.run(entry.content, options: r_args)
        #when "application/xhtml+xml", "application/x-dtbncx+xml", "application/oebps-package+xml"
        else
          xml_doc = UMPTG::XML.parse(xml_content: entry.content)
          @logger.error("#{entry.name}: #{xml_doc.errors.count} parse errors") unless xml_doc.errors.empty?

          run_args[:entry] = entry
          result = processor.run(xml_doc, options: run_args, logger: @logger)
        end

        entry_actions << UMPTG::EPUB::EntryActions.new(
                  entry: entry,
                  action_result: result
                  ) \
           unless result.nil?
      end

      entry_actions.each do |ea|
        @logger.info("Entry: #{ea.entry.name}")

        # Report results
        UMPTG::Pipeline::Action.resolve_issues(
              ea.action_result.issues,
              logger: @logger,
              options: {
                    normalize: false,
                    display_msgs: true
                  }
              )
        #ea.action_result.actions.each {|a| @logger.info(a) }

        if ea.action_result.modified or args[:save_forced]
          @logger.info("Updating entry #{ea.entry.name}")

          media_type = ea.entry.media_type.to_s
          #unless media_type == "text/css"
            case media_type
            when "text/css"
              content = ea.action_result.issues.first.content
            else
              fact = ea.action_result.issues.first
              entry_xml_doc = fact.nil? ? \
                    UMPTG::XML.parse(xml_content: ea.entry.content) : \
                    fact.reference_node.document
              content = UMPTG::XML.doc_to_xml(entry_xml_doc)
            end
            epub.files.add(
                  entry_name: ea.entry.name,
                  entry_content: content
                )
          #end
        end
      end
      type_cnt = {
            UMPTG::Message.INFO => 0,
            UMPTG::Message.WARNING => 0,
            UMPTG::Message.ERROR => 0,
            UMPTG::Message.FATAL => 0
      }
      entry_actions.each do |ea|
        ea.action_result.issues.each do |issue|
          issue.actions.each do |action|
            action.messages.each do |msg|
              type_cnt[msg.level] += 1
            end
          end
        end
      end

      case
      when type_cnt[UMPTG::Message.FATAL] > 0
        logger.fatal("Fatal:#{type_cnt[UMPTG::Message.FATAL]}  Error:#{type_cnt[UMPTG::Message.ERROR]}  Warning:#{type_cnt[UMPTG::Message.WARNING]}")
      when type_cnt[UMPTG::Message.ERROR] > 0
        logger.error("Error:#{type_cnt[UMPTG::Message.ERROR]}  Warning:#{type_cnt[UMPTG::Message.WARNING]}")
      when type_cnt[UMPTG::Message.WARNING] > 0
        logger.warn("Warning:#{type_cnt[UMPTG::Message.WARNING]}")
      else
        logger.info("Error: 0")
      end
      @logger.info("Normalization not necessary.") unless epub.modified

      return entry_actions
    end

    def report(args = {})
      entry_actions = args[:entry_actions]
      llogger = args[:logger] || @logger

      a = args.clone
      a[:logger] = llogger

      @processors.each do |k,p|
        issues = []
        entry_actions.each do |ea|
          issues += ea.action_result.issues if ea.entry.media_type == k
        end

        p.report_issues(
              issues,
              logger: llogger,
              options: {process_results: true}
            )
      end
    end

    def filters()
      f_list = []
      f_list = @processors.values.collect {|p| p.filters }
      return f_list
    end
  end
end
