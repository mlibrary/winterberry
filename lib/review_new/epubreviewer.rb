module UMPTG::Review
  class EPUBReviewer

    @@REVIEW_PROCESSORS = {
          link: LinkProcessor.new,
          list: ListProcessor.new,
          package: PackageProcessor.new,
          resources: ResourceProcessor.new,
          table: TableProcessor.new
        }

    attr_reader :epub, :epub_modified, :review_logger, :action_map

    def initialize(args = {})
      # Determine the EPUB to use.
      case
      when args.key?(:epub_file)
        @epub = UMPTG::EPUB::Archive.new(epub_file: args[:epub_file])
      when args.key?(:epub)
        @epub = args[:epub]
      else
        raise "Error no EPUB specified"
      end

      # Init log file. Use specified path or STDOUT.
      case
      when args.key?(:logger_file)
        logger_file = args[:logger_file]
        @review_logger = Logger.new(File.open(logger_file, File::WRONLY | File::TRUNC | File::CREAT))
      when args.key?(:logger)
        @review_logger = args[:logger]
      else
        @review_logger = Logger.new(STDOUT)
      end
      @review_logger.formatter = proc do |severity, datetime, progname, msg|
        "#{severity}: #{msg}\n"
      end

      @action_map = {}
      @epub_modified = false
    end

    def review(args = {})
      review_options = args[:review_options]
      normalize = args.key?(:normalize) ? args[:normalize] : false

      review_processors = @@REVIEW_PROCESSORS.select {|key,proc| review_options[key] == true }

      # Process the epub and generate the image information.
      @action_map = UMPTG::EPUB::Processor.process(
            epub: @epub,
            entry_processors: review_processors,
            process_opf: review_options[:package],
            pass_xml_doc: true,
            logger: @review_logger
          )

      @action_map.each do |entry_name,proc_map|
        proc_map.each do |key,action_list|
          next if action_list.nil?
          action_list.each do |action|
            next if action.class.superclass.to_s == "UMPTG::Review::NormalizeAction" and normalize == false
            action.process
          end
        end
      end

      issue_cnt = {
            UMPTG::Message.INFO => 0,
            UMPTG::Message.WARNING => 0,
            UMPTG::Message.ERROR => 0,
            UMPTG::Message.FATAL => 0
      }

      @epub_modified = false
      @action_map.each do |entry_name,proc_map|
        @review_logger.info(entry_name)

        update_entry = false
        proc_map.each do |key,action_list|
          next if action_list.nil?
          action_list.each do |action|
            if action.status == UMPTG::Review::NormalizeAction.NORMALIZED
              update_entry = true
            end
            action.review_msg_list.each do |msg|
              case msg.level
              when UMPTG::Message.INFO
                @review_logger.info(msg.text)
              when UMPTG::Message.WARNING
                @review_logger.warn(msg.text)
              when UMPTG::Message.ERROR
                @review_logger.error(msg.text)
              when UMPTG::Message.FATAL
                @review_logger.fatal(msg.text)
              end
              issue_cnt[msg.level] += 1
            end
          end
        end
        if update_entry
          @review_logger.info("Updating entry #{entry_name}")
          xml_doc = proc_map[:xml_doc]
          @epub.add(entry_name: entry_name, entry_content: UMPTG::XMLUtil.doc_to_xml(xml_doc))
          @epub_modified = true
        end
      end
=begin
      if epub_modified
        epub_normalized_file = File.join(File.dirname(@epub.epub_file), File.basename(@epub.epub_file, ".*") + "_normal.epub")
        @review_logger.info("Saving normalized EPUB \"#{File.basename(epub_normalized_file)}.")
        @epub.save(epub_file: epub_normalized_file)
      end
=end

      case
      when issue_cnt[UMPTG::Message.FATAL] > 0
        @review_logger.fatal("Fatal:#{issue_cnt[UMPTG::Message.FATAL]}  Error:#{issue_cnt[UMPTG::Message.ERROR]}  Warning:#{issue_cnt[UMPTG::Message.WARNING]}")
      when issue_cnt[UMPTG::Message.ERROR] > 0
        @review_logger.error("Error:#{issue_cnt[UMPTG::Message.ERROR]}  Warning:#{issue_cnt[UMPTG::Message.WARNING]}")
      when issue_cnt[UMPTG::Message.WARNING] > 0
        @review_logger.warn("Warning:#{issue_cnt[UMPTG::Message.WARNING]}")
      else
        @review_logger.info("Error: 0")
      end
    end

    def resource_path_list()
      return @@REVIEW_PROCESSORS[:resources].resource_path_list
    end
  end
end