module UMPTG::EPUB
  require_relative(File.join("..", "object"))
  require_relative(File.join("..", "action"))
  require_relative(File.join("..", "logger"))

  require_relative("entryactions")

  class XProcessor < UMPTG::Object
    attr_accessor :logger, :xml_processor

    def initialize(args = {})
      super(args)

      @logger = @properties.key?(:logger) ? @properties[:logger] : UMPTG::Logger.create(logger_fp: STDOUT)
      @xml_processor = @properties[:xml_processor]
    end

    def run(epub, args = {})
      raise "No XML processor specified" if @xml_processor.nil?

      run_args = args.clone()

      # Set XML processor logger to be this logger.
      @xml_processor.logger = @logger

      # Indicate the options selected for this run.
      @xml_processor.display_options()

      entry_actions = []

      # Process the EPUB OPF if that filter is provided.
      filters = @xml_processor.filters
      opf_filter = filters.select {|f| f.name == :package }.first
      unless opf_filter.nil?
        xml_doc = UMPTG::XML.parse(xml_content: epub.opf.content)
        actions = opf_filter.run(xml_doc, args)

        run_args[:actions] = actions
        result = UMPTG::XML::Pipeline::Action::Action.process_actions(run_args)
        entry_actions << EntryActions.new(
                  entry: epub.opf,
                  action_result: result
                  )
      end

      # Process EPUB spine.
      filters = filters.delete_if {|f| f.name == :package }
      unless filters.empty?
        sv_filters = @xml_processor.filters
        @xml_processor.filters = filters

        epub.spine.each do |entry|
          xml_doc = UMPTG::XML.parse(xml_content: entry.content)
          result = @xml_processor.run(xml_doc, args)
          entry_actions << EntryActions.new(
                    entry: entry,
                    action_result: result
                    )
        end
        @xml_processor.filters = sv_filters
      end

      entry_actions.each do |ea|
        @logger.info("Entry: #{ea.entry.name}")

        # Report results
        UMPTG::XML::Pipeline::Action::Action.report_actions(
              actions: ea.action_result.actions,
              logger: @logger
              )
        #ea.action_result.actions.each {|a| @logger.info(a) }

        if ea.action_result.modified
          @logger.info("Updating entry #{ea.entry.name}")
          entry_xml_doc = ea.action_result.actions.first.reference_node.document
          epub.add(entry_name: ea.entry.name, entry_content: UMPTG::XML.doc_to_xml(entry_xml_doc))
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
  end
end
