module UMPTG::EPUB
  class Processor
    def self.process(args = {})
      logger = args[:logger]

      case
      when args.key?(:epub_file)
        epub_file = File.expand_path(args[:epub_file])
        logger.fatal("Error: invalid EPUB file.") unless File.exists?(epub_file)
        epub = UMPTG::EPUB::Archive.new(:epub_file => epub_file) if epub.nil?
      when args.key?(:epub)
        epub = args[:epub]
        logger.fatal("Error: invalid EPUB.") if epub.nil?
      else
        logger.fatal("Error: no :epub_file or :epub parameter specified.")
      end

      logger.fatal("Error: missing :entry_processors parameter.") unless args.key?(:entry_processors)
      entry_processors = args[:entry_processors]
      logger.fatal("Error: no entry_processors specified.") if entry_processors.nil? or entry_processors.empty?

      # Parameter indicates whether content should be provided as
      # string or as a XML doc.
      pass_xml_doc = args.key?(:pass_xml_doc) and args[:pass_xml_doc]

      epub_actions = {}
      epub.spine.each do |entry|
        epub_actions[entry.name] = {}

        if pass_xml_doc
          content = nil
          xml_doc = UMPTG::XMLUtil.parse(xml_content: entry.content)
        else
          content = entry.content
          xml_doc = nil
        end
        epub_actions[entry.name][:xml_doc] = xml_doc

        entry_processors.each do |key,processor|
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
