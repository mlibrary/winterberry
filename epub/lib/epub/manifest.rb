module UMPTG::EPUB

  class Manifest < UMPTG::Object

    def initialize(args = {})
      super(args)

      @opf_entry = args[:entry]
      raise "missing rendition entry for manifest" if @opf_entry.nil?

      @manifest_node = @opf_entry.document.xpath("//*[local-name()='manifest']").first
      raise "missing manifest element" if @manifest_node.nil?
    end

    def find(args = {})
      entry_name = args[:entry_name]
      raise "missing entry name for manifest" if entry_name.nil? or entry_name.strip.empty?

      item_node = @manifest_node.xpath("./*[local-name()='item' and @href='#{entry_name}']").first
      return item_node
    end

    def add(args = {})
    end
  end
end
