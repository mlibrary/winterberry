module UMPTG::EPUB

  class Rendition < UMPTG::Object
    attr_reader :epub, :entry, :manifest, :navigation, :spine

    DEFAULT_PATH = File.join("OEBPS", "content.opf")

    DEFAULT_XML_TEMPLATE = <<-PKG
<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="pub-id" dir="ltr" xml:lang="en">
<metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opf="http://www.idpf.org/2007/opf">
<dc:identifier id="pub-id">pubid</dc:identifier>
<dc:title>Ebook Title</dc:title>
<dc:language>en</dc:language>
</metadata>
<manifest>
%s
</manifest>
<spine/>
</package>
    PKG

    def initialize(args = {})
      super(args)

      @epub = args[:epub]
      @entry = args[:archive_entry]

      @manifest = Manifest.new(args)
      @spine = Spine.new(archive_entry: @entry, manifest: @manifest)

      manifest_nav_node = @manifest.navigation(args)
      nav_href = Manifest.MK_PATH(@entry, manifest_nav_node["href"])
      nav_entry = @entry.archive.find(entry_name: nav_href)
      @navigation = Navigation.new(rendition: self, archive_entry: nav_entry)
    end

    def toc
      return @navigation.toc
    end

    def self.DEFAULT_PATH
      return DEFAULT_PATH
    end

    def self.DEFAULT_XML
      return sprintf(DEFAULT_XML_TEMPLATE, Navigation.MANIFEST_ITEM_XML)
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
