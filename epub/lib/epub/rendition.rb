module UMPTG::EPUB

  class Rendition < UMPTG::Object
    attr_reader :name, :document, :navigation_doc

    TEMPLATE = <<-PKG
<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="pub-id" dir="ltr" xml:lang="en">
<metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opf="http://www.idpf.org/2007/opf">
<dc:identifier id="pub-id">pubid</dc:identifier>
<dc:title>Ebook Title</dc:title>
<dc:language>en</dc:language>
</metadata>
<manifest></manifest>
<spine></spine>
</package>
    PKG

    NAVIGATION_TEMPLATE = <<-NTEMP
<?xml version="1.0" encoding="UTF-8"?>
<html lang="en-US" xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
<head><title>Navigation</title></head>
<body>
<nav id="toc" role="doc-toc" epub:type="toc" aria-labelledby="nav_toc">
<h2 id="nav_toc" epub:type="title">Table of Contents</h2>
<ol style="list-style-type:none;">
<li></li>
</ol>
</nav>
</body>
</html>
    NTEMP

    def initialize(args = {})
      super(args)

      @name = args[:rendition_name]
      raise "rendition name is required" if @name.nil? or @name.strip.empty?

      @document = Nokogiri::XML(TEMPLATE)
      @navigation_doc = Nokogiri::XML(NAVIGATION_TEMPLATE)

      man_node = Rendition.find_node(@document, "manifest")
      man_node.add_child('<item id="nav" properties="nav" href="navigation.xhtml" media-type="application/xhtml+xml"/>')
    end

    def write(output_stream, args = {})
      opf_doc = @document.clone

      modified_date = Time.now.strftime("%Y-%m-%dT%H:%M:%S") + "Z"
      meta_node = Rendition.find_node(opf_doc, "metadata")
      meta_node.add_child("<meta property=\"dcterms:modified\">#{modified_date}</meta>")

      Entry.write(
          output_stream,
          entry_name: File.join("OEBPS", @name + ".opf"),
          entry_content: opf_doc.to_xml
        )

      nav_node = @document.xpath("//*[local-name()='manifest']/*[local-name()='item' and @properties='nav']").first
      unless nav_node.nil?
        href = nav_node['href']
        Entry.write(
            output_stream,
            entry_name: File.join("OEBPS", href),
            entry_content: navigation_doc.to_xml
          )
      end
    end

    def self.add_modified(opf_doc, args = {})
      value = args[:value]
      value = "" if value.nil? or value.strip.empty?

      meta_node = opf_doc.xpath("//*[local-name()='metadata']").first
      raise "missing metadata node" if meta_node.nil?

      meta_node.add_child("<meta property=\"dcterms:modified\">#{value}</meta>")
    end

    private

    def self.find_node(doc, elem_name)
      node = doc.xpath("//*[local-name()='#{elem_name}']").first
      raise "missing #{elem_name} node" if node.nil?
      return node
    end
  end
end
