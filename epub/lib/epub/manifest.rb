module UMPTG::EPUB

  class Manifest < UMPTG::Object

    ITEM_TEMPLATE = <<-XMLTEMP
<item id="%s" href="%s" media-type="%s"/>
    XMLTEMP

    def initialize(args = {})
      super(args)

      @opf_entry = args[:entry]
      raise "missing rendition entry for manifest" if @opf_entry.nil?

      @manifest_node = @opf_entry.document.xpath("//*[local-name()='manifest']").first
      raise "missing manifest element" if @manifest_node.nil?
    end

    def find(args = {})
      entry_name = args[:entry_name]
      raise "manifest find: missing entry name" if entry_name.nil? or entry_name.strip.empty?

      item_node = @manifest_node.xpath("./*[local-name()='item' and @href='#{entry_name}']").first
      return item_node
    end

    def add(args = {})
      entry_mediatype = args[:entry_mediatype]
      raise "manifest add: missing entry media-type" if entry_mediatype.nil? or entry_mediatype.strip.empty?
      entry_mediatype.strip!

      entry = @opf_entry.archive.add(args)

      entry_id = args[:entry_id]
      entry_id = "item_" + entry.name.gsub(/[ \/\.\,\-]+/, '_') if entry_id.nil? or entry_id.strip.empty?
      entry_properties = args[:entry_properties]

      markup = sprintf(ITEM_TEMPLATE, entry_id, entry.name, entry_mediatype)
      n = @manifest_node.add_child(markup)
      n['properties'] = entry_properties unless entry_properties.nil? or entry_properties.strip.empty?
      return entry
    end
  end
end
