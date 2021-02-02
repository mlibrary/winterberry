module UMPTG::Keywords

  require 'zip'

  # Class processes the keywords found within an EPUB.
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
      monograph_noid = args[:noid]
      raise "Error: missing NOID" if monograph_noid.nil?

      log = args[:log]

      keyword_processor = UMPTG::Keywords::KeywordProcessor.new(
                  noid: monograph_noid,
                  log: log
                  )

      # Process the epub. Returned is a hash table where each
      # item key is an EPUB entry name and the item value is
      # a list of processing actions.
      processors = { keywords: keyword_processor }
      action_map = UMPTG::EPUB::Processor.process(
            epub: epub,
            entry_processors: processors
          )

      action_map.each do |entry_name,action_list|
        # Action list for this EPUB entry. Determine if
        # at least one Action within the list completed
        # successfully.
        log.puts entry_name
        result = false

        action_list.each do |action|
          log.puts action
          unless result
            result = action.status == UMPTG::Action.COMPLETED
          end
        end

        if result
          # At last one action was completed. Remember that this
          # file was updated.
          doc = action_list.first.keyword_container.document

          # Update the entry in the EPUB. Remove old entry and
          # add the new one.
          epub.remove(entry_name: entry_name)
          epub.add(entry_name: entry_name, entry_content: UMPTG::XMLUtil.doc_to_xml(doc))
        end
      end

      # Return the modified EPUB
      return epub
    end
  end
end

