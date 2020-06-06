
require 'zip'

class ElemProcessor < FragmentProcessor
end

class ContainerSaxDocument < FragmentSaxDocument

  attr_accessor :containers

  def select_fragment(name, attrs = [])
    return @containers.include?(name)
  end
end

class Epub
  @@elem_processor = ElemProcessor.new

  def initialize(args = {})
    @epub_file = args[:epub_file]
    reset
  end

  def opf_item
    do_init
    return @opf_item
  end

  def metadata
    do_init
    return @metadata
  end

  def spine_items
    do_init
    return unless @spine_items.nil?

    opf_dir = File.dirname(@opf_item.name)
    @spine_items = []
    itemref_list = @spine.node.xpath(".//*[local-name()='itemref']")
    itemref_list.each do |itemref|
      idref = itemref['idref']
      item = @manifest.node.xpath(".//*[local-name()='item' and @id=\"#{idref}\"]").first
      raise "Error: finding manifest item #{idref}" if item.nil?

      item_entry = @file.glob(File.join(opf_dir, item['href'])).first
      raise "Error: loading manifest item #{item['href']}" if item_entry.nil?

      @spine_items << item_entry
    end
    return @spine_items
  end

  def reset
    @file = nil
    @opf_item = nil
    @metadata = nil
    @manifest = nil
    @spine = nil
    @spine_items = nil
  end

  private

  def do_init
    return unless @file.nil?

    Zip::File.open(@epub_file) do |file|
      @file = file

      containers = file.glob(File.join("META-INF", "container.xml"))
      return nil if containers.empty?
      container_entry = containers.first

      selectproc = ContainerSaxDocument.new
      selectproc.containers = [ 'rootfile' ]
      fragment_list = @@elem_processor.process(
            :content => container_entry.get_input_stream.read,
            :selectproc => selectproc
          )
      return nil if fragment_list.empty?

      root_elem = fragment_list.first.node
      opf_file = root_elem['full-path']
      opf_dir = File.dirname(opf_file)
      @opf_item = file.glob(opf_file).first

      selectproc.containers = [ 'metadata' ]
      @metadata = @@elem_processor.process(
            :content => @opf_item.get_input_stream.read,
            :selectproc => selectproc
          ).first
      selectproc.containers = [ 'manifest' ]
      @manifest = @@elem_processor.process(
            :content => @opf_item.get_input_stream.read,
            :selectproc => selectproc
          ).first
      selectproc.containers = [ 'spine' ]
      @spine = @@elem_processor.process(
            :content => @opf_item.get_input_stream.read,
            :selectproc => selectproc
          ).first

    end
  end
end
