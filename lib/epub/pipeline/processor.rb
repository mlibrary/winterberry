module UMPTG::EPUB::Pipeline

  class Processor < UMPTG::Object
    attr_reader :processors
    attr_accessor :logger

    def initialize(args = {})
      a = args.clone
      a2 = args.clone

      a2[:name] = a[:name] || "EPUBProcessor"

      a[:name] = "NCXProcessor"
      a2[:ncx_processor] = UMPTG::EPUB::NCX::Processor(a) \
                 if a2[:ncx_procesor].nil?

      a[:name] = "OEBPSProcessor"
      a2[:oebps_processor] = UMPTG::EPUB::OEBPS::Processor(a) \
                 if a2[:oebps_processor].nil?

      a[:name] = "FulcrumXHTMLProcessor"
      a2[:xhtml_processor] = UMPTG::XHTML::Processor(a) \
                 if a2[:xhtml_processor].nil?

      a[:name] = "XMLProcessor"
      a2[:xml_processor] = UMPTG::XML::Processor(a) \
                 if a2[:xml_processor].nil?

      super(a2)

      @logger = @properties.key?(:logger) ? @properties[:logger] : UMPTG::Logger.create(logger_fp: STDOUT)

      @processors = {
                "application/x-dtbncx+xml" => @properties[:ncx_processor],
                "application/oebps-package+xml" => @properties[:oebps_processor],
                "application/xhtml+xml" => @properties[:xhtml_processor],
                "text/html" => @properties[:xhtml_processor],
                "text/xml" => @properties[:xml_processor]
            }
    end

    def run(epub, args = {})
      # Indicate the options selected for this run.
      @processors.values.each do |processor|
        processor.logger = @logger
        processor.display_options()
        processor.logger = nil
      end

      entry_actions = []

      ([epub.rendition.entry] + epub.rendition.manifest.entries).each do |entry|
        processor = @processors[entry.media_type.to_s]
        if processor.nil?
          @logger.warn("#{entry.name}, no processor for media type #{entry.media_type}")
          next
        end

        xml_doc = UMPTG::XML.parse(xml_content: entry.content)
        @logger.error("#{entry.name}: #{xml_doc.errors.count} parse errors") unless xml_doc.errors.empty?

        result = processor.run(xml_doc, args)

        entry_actions << UMPTG::EPUB::EntryActions.new(
                  entry: entry,
                  action_result: result
                  ) \
           unless result.nil?
      end

      entry_actions.each do |ea|
        @logger.info("Entry: #{ea.entry.name}")

        # Report results
        UMPTG::XML::Pipeline::Action.process_actions(
              actions: ea.action_result.actions,
              logger: @logger,
              normalize: false,
              display_msgs: false
              )
        #ea.action_result.actions.each {|a| @logger.info(a) }

        if ea.action_result.modified
          @logger.info("Updating entry #{ea.entry.name}")
          entry_xml_doc = ea.action_result.actions.first.reference_node.document
          #epub.add(entry_name: ea.entry.name, entry_content: UMPTG::XML.doc_to_xml(entry_xml_doc))
          epub.files.add(
                entry_name: ea.entry.name,
                entry_content: UMPTG::XML.doc_to_xml(entry_xml_doc)
              )
        end
      end

      type_cnt = {
            UMPTG::Message.INFO => 0,
            UMPTG::Message.WARNING => 0,
            UMPTG::Message.ERROR => 0,
            UMPTG::Message.FATAL => 0
      }
      entry_actions.each do |ea|
        ea.action_result.actions.each do |action|
          action.messages.each do |msg|
            type_cnt[msg.level] += 1
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

    def process_entry_action_results(args = {})
      entry_actions = args[:entry_actions]
      llogger = args[:logger] || @logger

      a = args.clone
      a[:logger] = llogger

      @processors.each do |k,p|
        action_results = []
        entry_actions.each do |ea|
          action_results << ea.action_result if ea.entry.media_type == k
        end

        a[:action_results] = action_results
        p.process_action_results(a)
      end
    end

    def filters()
      f_list = []
      f_list = @processors.values.collect {|p| p.filters }
      return f_list
    end
  end
end
