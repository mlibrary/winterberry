module UMPTG::Review
  class EPUBExtractor < EPUBProcessor

    @@PROCESSORS = {
          #resources: ResourcesExtractMediaDisplayProcessor.new,
          resources: ResourcesExtractIframeProcessor.new,
          package: PackageExtractMediaDisplayProcessor.new
        }

    def initialize(args = {})
      super(args)
    end

    def extract(args = {})
      extract_options = args[:extract_options]

      @logger.info("Extract EPUB")

      processors = @@PROCESSORS.select {|key,proc| extract_options[key] == true }
      processors[:resources].manifest = @properties[:manifest]

      @epub_modified = false
      epub.entries.each do |entry|
        if entry.name.include?("fulcrum_default.css")
          epub.remove(entry_name: entry.name)
          @logger.info("removed entry #{entry.name}")
          @epub_modified = true
        end
      end

      # Process the epub and generate the image information.
      @action_map = UMPTG::EPUB::Processor.process(
            epub: @epub,
            entry_processors: processors,
            process_opf: true,
            pass_xml_doc: true,
            logger: @logger
          )

      @action_map.each do |entry_name,proc_map|
        proc_map.each do |key,action_list|
          next if action_list.nil?
          action_list.each do |action|
            action.process()
          end
        end
      end

      issue_cnt = {
            UMPTG::Message.INFO => 0,
            UMPTG::Message.WARNING => 0,
            UMPTG::Message.ERROR => 0,
            UMPTG::Message.FATAL => 0
      }

      @action_map.each do |entry_name,proc_map|
        @logger.info(entry_name)

        update_entry = false
        proc_map.each do |key,action_list|
          next if action_list.nil?
          action_list.each do |action|
            update_entry = true if action.status == UMPTG::Review::NormalizeAction.NORMALIZED
            action.messages.each do |msg|
              case msg.level
              when UMPTG::Message.INFO
                @logger.info(msg.text)
              when UMPTG::Message.WARNING
                @logger.warn(msg.text)
              when UMPTG::Message.ERROR
                @logger.error(msg.text)
              when UMPTG::Message.FATAL
                @logger.fatal(msg.text)
              end
              issue_cnt[msg.level] += 1
            end
          end
        end
        if update_entry
          @logger.info("Updating entry #{entry_name}")
          xml_doc = proc_map[:xml_doc]
          @epub.add(entry_name: entry_name, entry_content: UMPTG::XMLUtil.doc_to_xml(xml_doc))
          @epub_modified = true
        end
      end

      case
      when issue_cnt[UMPTG::Message.FATAL] > 0
        @logger.fatal("Fatal:#{issue_cnt[UMPTG::Message.FATAL]}  Error:#{issue_cnt[UMPTG::Message.ERROR]}  Warning:#{issue_cnt[UMPTG::Message.WARNING]}")
      when issue_cnt[UMPTG::Message.ERROR] > 0
        @logger.error("Error:#{issue_cnt[UMPTG::Message.ERROR]}  Warning:#{issue_cnt[UMPTG::Message.WARNING]}")
      when issue_cnt[UMPTG::Message.WARNING] > 0
        @logger.warn("Warning:#{issue_cnt[UMPTG::Message.WARNING]}")
      else
        @logger.info("Error: 0")
      end

      unless epub_modified
        @logger.info("Extraction not necessary.")
      end
    end
  end
end
