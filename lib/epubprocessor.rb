require_relative 'epub'

class EpubProcessor

  def self.process(args = {})
    case
    when args.has_key?(:epub_file)
      epub_file = File.expand_path(args[:epub_file])
      raise "Error: invalid EPUB file." unless File.exists?(epub_file)
      epub = nil
    when args.has_key?(:epub)
      epub = args[:epub]
      raise "Error: invalid EPUB." if epub.nil?
    else
      raise "Error: no :epub_file or :epub parameter specified."
    end
    if epub.nil?
      epub = Epub.new(:epub_file => epub_file)
    end

    raise "Error: missing :processors parameter." unless args.has_key?(:processors)
    processors = args[:processors]
    raise "Error: no processors specified." if processors.nil? or processors.empty?

    item_fragments = {}
    epub.spine_items.each do |item|
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