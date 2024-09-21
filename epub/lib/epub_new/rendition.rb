module UMPTG::EPUB

  class Rendition < UMPTG::Object
    attr_reader :epub

    OPF_PATH = File.join("OEBPS", "content.opf")

    OPF_XML = <<-PKG
<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="pub-id" dir="ltr" xml:lang="en">
<metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opf="http://www.idpf.org/2007/opf">
<dc:identifier id="pub-id">pubid</dc:identifier>
<dc:title>Ebook Title</dc:title>
<dc:language>en</dc:language>
</metadata>
<manifest/>
<spine/>
</package>
    PKG

    def initialize(args = {})
      super(args)

      @epub = args[:epub]
      @entry = args[:entry]

      @manifest = nil
      @spine = nil
      @navigation = nil
    end

    def aentry
      @entry = @epub.container.add(
            entry_name: OPF_PATH,
            entry_content: OPF_XML
          ) if @entry.nil?
      return @entry
    end

    def manifest
      @manifest = Manifest.new(rendition: self) if @manifest.nil?
      return @manifest
    end

    def spine
      @spine = Spine.new(rendition: self) if @spine.nil?
      return @spine
    end

    def navigation
      e_list = @manifest.navigation.collect {|n| @epub.archive.find(entry_name: n['href']) }
      @navigation = Navigation.new(
              rendition: self,
              entry: e_list.first
          ) if @navigation.nil?
      return @navigation
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
