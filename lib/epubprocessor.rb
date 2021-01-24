module UMPTG
  require_relative 'epub'

  class EpubProcessor
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

      raise "Error: missing :processors parameter." unless args.has_key?(:processors)
      processors = args[:processors]
      raise "Error: no processors specified." if processors.nil? or processors.empty?

      item_fragments = {}

      epub_items = [ epub.opf ] + epub.spine
      epub_items.each do |item|
        fragments_list = []
        processors.each do |proc|
          fragments = proc.process(
                  :name => item.name,
                  :content => item.get_input_stream.read
                )
          fragments_list += fragments
        end
        item_fragments[item.name] = fragments_list
      end
      return item_fragments
    end
  end
end
