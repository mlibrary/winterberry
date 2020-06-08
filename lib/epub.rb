
require 'zip'

class ContainerSelector

  attr_accessor :containers

  def select_fragment(name, attrs = [])
    return @containers.include?(name)
  end
end

class Epub
  def initialize(args = {})
    @epub_file = args[:epub_file]
    reset
  end

  def opf_item
    load_epub if @opf_item.nil?
    return @opf_item
  end

  def metadata_node
    load_epub if @metadata.nil?
    return @metadata
  end

  def spine_items
    if @spine_items.nil?
      load_epub

      opf_dir = File.dirname(@opf_item.name)
      @spine_items = []
      itemref_list = @spine.node.xpath(".//*[local-name()='itemref']")
      itemref_list.each do |itemref|
        idref = itemref['idref']
        item = @manifest.node.xpath(".//*[local-name()='item' and @id=\"#{idref}\"]").first
        raise "Error: finding manifest item #{idref}" if item.nil?

        item_entry = @epub.glob(File.join(opf_dir, item['href'])).first
        raise "Error: loading manifest item #{item['href']}" if item_entry.nil?

        @spine_items << item_entry
      end
    end

    return @spine_items
  end

  def reset
    @epub = nil
    @opf_item = nil
    @metadata = nil
    @manifest = nil
    @spine = nil
    @spine_items = nil
  end

  private

  def load_epub
    if @epub.nil?
      fragment_processor = FragmentProcessor.new
      fragment_selector = ContainerSelector.new

      Zip::File.open(@epub_file) do |epub|
        @epub = epub

        containers = epub.glob(File.join("META-INF", "container.xml"))
        return nil if containers.empty?
        container_entry = containers.first

        fragment_selector.containers = [ 'rootfile' ]
        fragment_list = fragment_processor.process(
              :content => container_entry.get_input_stream.read,
              :selector => fragment_selector
            )
        return nil if fragment_list.empty?

        root_elem = fragment_list.first.node
        opf_file = root_elem['full-path']
        opf_dir = File.dirname(opf_file)
        @opf_item = epub.glob(opf_file).first

        fragment_selector.containers = [ 'metadata' ]
        @metadata = fragment_processor.process(
              :content => @opf_item.get_input_stream.read,
              :selector => fragment_selector
            ).first
        fragment_selector.containers = [ 'manifest' ]
        @manifest = fragment_processor.process(
              :content => @opf_item.get_input_stream.read,
              :selector => fragment_selector
            ).first
        fragment_selector.containers = [ 'spine' ]
        @spine = fragment_processor.process(
              :content => @opf_item.get_input_stream.read,
              :selector => fragment_selector
            ).first
      end
    end
  end
end
