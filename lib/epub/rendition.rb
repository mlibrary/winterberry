module UMPTG::EPUB

  class Rendition
    attr_reader :label, :opf_item, :metadata, :manifest, :spine, :is_text_rendition
    alias_method :text_rendition?, :is_text_rendition

    def initialize(args = {})
      load(args)
    end

    def load(args = {})
      @archive = args[:archive]
      raise "Error: missing archive" if @archive.nil?

      opf_file = args[:opf_file]
      raise "Error: missing rendition OPF." if opf_file.nil?

      @opf_item = @archive.glob(opf_file).first
      raise "Error: missing rendition OPF." if @opf_item.nil?

      @label = args[:label]

      @is_text_rendition = @label.nil? ? false : @label.downcase == 'text'

      fragment_processor = UMPTG::Fragment::Processor.new
      fragment_selector = UMPTG::Fragment::ContainerSelector.new

      fragment_selector.containers = [ 'manifest', 'metadata', 'spine' ]
      fragments = fragment_processor.process(
            :content => @opf_item.get_input_stream.read,
            :selector => fragment_selector
          )
      fragments.each do |fragment|
        case fragment.node.name
        when 'manifest'
          @manifest = fragment
        when 'metadata'
          @metadata = fragment
        when 'spine'
          @spine = fragment
        end
      end
    end

    def spine_items
      if @spine_items.nil?
        opf_dir = File.dirname(@opf_item.name)

        @spine_items = []
        itemref_list = @spine.node.xpath(".//*[local-name()='itemref']")
        itemref_list.each do |itemref|
          idref = itemref['idref']
          item = @manifest.node.xpath(".//*[local-name()='item' and @id=\"#{idref}\"]").first
          raise "Error: finding manifest item #{idref}" if item.nil?

          # This sometimes fails, but not sure why the path
          # within the epub should vary depending on whether
          # the OPF is in the same directory or not.
          #item_entry = File.join(opf_dir, item['href'])
          #item_entry = item['href']
          item_entry = @archive.glob(File.join(opf_dir, item['href'])).first
          #item_entry = @archive.glob(item['href']).first

          @spine_items << item_entry
        end
      end
      return @spine_items
    end

    def nav_items
      return @manifest.node.xpath(".//*[local-name()='item' and contains(concat(' ',translate(@properties, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), ' '),' nav ')]")
    end

    def ncx_items
      return @manifest.node.xpath(".//item[@media-type = 'application/x-dtbncx+xml']")
    end
  end
end
