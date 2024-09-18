module UMPTG::EPUB

  class Rendition < UMPTG::Object

    def initialize(args = {})
      super(args)

      @opf_entry = args[:entry]
      raise "missing rendition entry" if @opf_entry.nil?

      nav_node = @opf_entry.document.xpath("//*[local-name()='manifest']/*[local-name()='item' and @properties='nav']").first
      @nav_entry = @entry.archive.find(entry_name: nav_node['href'])
    end

    def self.add_modified(opf_doc, args = {})
      value = args[:value]
      value = "" if value.nil? or value.strip.empty?

      meta_node = opf_doc.xpath("//*[local-name()='metadata']").first
      raise "missing metadata node" if meta_node.nil?

      meta_node.add_child("<meta property=\"dcterms:modified\">#{value}</meta>")
    end
  end
end
