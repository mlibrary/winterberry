module UMPTG::Review
  class EPUBReviewer

    @@REVIEW_PROCESSORS = {
          keyword: KeywordProcessor.new,
          add_license: LicenseProcessor.new,
          section_type: SectionTypeProcessor.new,
          fix_img_ref: FixImageReferenceProcessor.new,
          link: LinkProcessor.new,
          list: ListProcessor.new,
          package: PackageProcessor.new,
          resources: ResourceProcessor.new,
          role_remove: RoleRemoveProcessor.new,
          media_convert: MediaConvertProcessor.new,
          move_coverrole: MoveCoverRoleProcessor.new,
          table: TableProcessor.new,
          url_wrap: URLWrapProcessor.new
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
      normalize_caption_class = args.key?(:normalize_caption_class) ? args[:normalize_caption_class] : false
      update_css = args.key?(:update_css) ? args[:update_css] : false

      @review_logger.info("Normalize EPUB:#{normalize}")
      @review_logger.info("Normalize caption classes:#{normalize_caption_class}")

      review_processors = @@REVIEW_PROCESSORS.select {|key,proc| review_options[key] == true }
      review_processors.each {|key,proc| proc.epub = @epub}

      if review_processors.key?(:add_license)
        rp = review_processors[:add_license]
        rp.license_file = args[:license_file]
        rp.license_fragment = args[:license_fragment]
        #rp.epub = @epub
      end

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
            if normalize or action.normalize == false
              action.process(
                      normalize_caption_class: normalize_caption_class
                    )
            end
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
      css_needs_update = false
      @action_map.each do |entry_name,proc_map|
        @review_logger.info(entry_name)

        update_entry = false
        proc_map.each do |key,action_list|
          next if action_list.nil?
          action_list.each do |action|
            if action.status == UMPTG::Review::NormalizeAction.NORMALIZED
              update_entry = true
              if update_css and action.class.name.end_with?("NormalizeFigureCaptionAction")
                css_needs_update = true
              end
            end
            action.messages.each do |msg|
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

      if css_needs_update
        css_entry_list = @epub.css

        require 'css_parser'

        centry = nil
        new_rule = nil
        parser = CssParser::Parser.new
        css_entry_list.each do |css_entry|
          parser.load_string!(css_entry.content)
          parser.find_rule_sets(['figcaption']).each do |rule|
            unless rule['font-size'].nil?
              if rule['font-size'].match?(/[\.]?[0-9]+em/)
                centry = css_entry
                new_rule = CssParser::RuleSet.new(rule.selectors.join(","), "")
                rule.each_declaration do |property,value,is_important|
                  v = is_important ? "#{value} !important" : value
                  new_rule.add_declaration!(property, v)
                end
                new_rule['font-size'] = new_rule['font-size'].sub(/([\.]?[0-9]+)em([^;]*)/, '\1rem\2')
              end
            end
          end
        end
        unless new_rule.nil?
          new_content = centry.content + "\n\n" + new_rule.to_s + "\n"
          @review_logger.info("Updating CSS entry #{centry.name}")
          @epub.add(entry_name: centry.name, entry_content: new_content)
        end
      end

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

      unless @epub_modified or !normalize
        @review_logger.info("Normalization not necessary.")
      end
    end

    def resource_path_list()
      return @@REVIEW_PROCESSORS[:resources].resource_path_list
    end
  end
end