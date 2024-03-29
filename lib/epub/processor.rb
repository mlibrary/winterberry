module UMPTG::EPUB
  class Processor
    def self.process(args = {})
      logger = args[:logger]

      case
      when args.key?(:epub_file)
        epub_file = File.expand_path(args[:epub_file])
        logger.fatal("Error: invalid EPUB file.") unless File.exist?(epub_file)
        epub = UMPTG::EPUB::Archive.new(:epub_file => epub_file) if epub.nil?
      when args.key?(:epub)
        epub = args[:epub]
        logger.fatal("Error: invalid EPUB.") if epub.nil?
      else
        logger.fatal("Error: no :epub_file or :epub parameter specified.")
      end

      logger.fatal("Error: missing :entry_processors parameter.") unless args.key?(:entry_processors)
      entry_processors = args[:entry_processors]
      if entry_processors.nil? or entry_processors.empty?
        logger.fatal("Error: no entry_processors specified.")
        raise "No entry_processors specified."
      end

      logger.info("Processing EPUB file #{File.basename(epub.epub_file)}")

      # Parameter indicates whether content should be provided as
      # string or as a XML doc.
      pass_xml_doc = args.key?(:pass_xml_doc) and args[:pass_xml_doc]

      entry_processors.each {|key,processor| processor.reset() }

      epub_actions = {}
      if entry_processors.key?(:package)
        entry = epub.opf
        if pass_xml_doc
          content = nil
          xml_doc = UMPTG::XMLUtil.parse(xml_content: entry.content)
        else
          content = entry.content
          xml_doc = nil
        end
        epub_actions[entry.name] = { xml_doc: xml_doc }

        entry_proc_actions = entry_processors[:package].action_list(
                    name: entry.name,
                    content: content,
                    logger: logger,
                    xml_doc: xml_doc
                    )
        epub_actions[entry.name][:package] = entry_proc_actions
      end

      epub.spine.each do |entry|
        if pass_xml_doc
          content = nil
          xml_doc = UMPTG::XMLUtil.parse(xml_content: entry.content)
        else
          content = entry.content
          xml_doc = nil
        end
        epub_actions[entry.name] = { xml_doc: xml_doc }

        entry_processors.each do |key,processor|
          next if key == :package

          entry_proc_actions = processor.action_list(
                      name: entry.name,
                      content: content,
                      logger: logger,
                      xml_doc: xml_doc
                      )
          epub_actions[entry.name][key] = entry_proc_actions
        end
      end
      return epub_actions
    end
  end
end
