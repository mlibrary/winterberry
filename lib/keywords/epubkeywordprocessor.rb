module UMPTG::Keywords

  require 'zip'

  class EpubKeywordProcessor
    def self.process(args = {})
      # EPUB parameter processing
      case
      when args.key?(:epub)
        epub = args[:epub]
        raise "Error: invalid EPUB." if epub.nil? or epub.class != "UMPTG::EPUB::Archive"
      when args.key?(:epub_file)
        # Create the EPUB from the specified file.
        epub_file = args[:epub_file]
        epub = UMPTG::EPUB::Archive.new(epub_file: epub_file)
      else
        raise "Error: :epub or :epub_file must be specified"
      end

      # NOID parameter
      noid = args[:noid]
      raise "Error: missing NOID" if noid.nil?

      reference_selector = UMPTG::Keywords::SpecKeywordSelector.new
      reference_processor = UMPTG::Keywords::ReferenceProcessor.new(
                  selector: reference_selector,
                  noid: noid
                  )
      keyword_processor = UMPTG::Keywords::KeywordProcessor.new(
                  reference_processor: reference_processor
                  )
      spine_items = epub.spine
      epub.spine.each do |item|
        puts "Processing file #{item.name}"
        STDOUT.flush

        # Create the XML tree.
        content = item.get_input_stream.read
        begin
          doc = Nokogiri::XML(content, nil, 'UTF-8')
        rescue Exception => e
          puts e.message
          next
        end

        # Determine the list of actions completed.
        # The -e flag must be specified for the actions
        # to be completed.
        action_list = keyword_processor.process(doc)
        result = action_list.index { |action| action.status == Action.COMPLETED }
        if result
          # Update the entry content
          epub.add(entry_name: item.name, entry_content: UMPTG::XMLUtil.doc_to_xml(doc))
        end
        puts "\n"
      end

      # Return the modified EPUB
      return epub
    end
  end
end

