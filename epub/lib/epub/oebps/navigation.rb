module UMPTG::EPUB::OEBPS

  class Navigation < UMPTG::Object
    attr_reader :entry, :rendition, :toc

    DEFAULT_PATH = File.join("OEBPS", "navigation.xhtml")

    DEFAULT_XML = <<-NTEMP
<?xml version="1.0" encoding="UTF-8"?>
<html lang="en-US" xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
<head><title>Navigation</title></head>
<body>
<nav id="toc" role="doc-toc" epub:type="toc" aria-labelledby="nav_toc">
<h2 id="nav_toc" epub:type="title">Table of Contents</h2>
<ol style="list-style-type:none;">
</ol>
</nav>
</body>
</html>
    NTEMP

    def initialize(args = {})
      super(args)

      @rendition = args[:rendition]
      @entry = args[:archive_entry]
      @toc = TOC.new(args)
    end

    def self.DEFAULT_PATH
      return DEFAULT_PATH
    end

    def self.DEFAULT_XML
      return DEFAULT_XML
    end

    def self.MANIFEST_ITEM_XML
      item_xml = sprintf(
            Manifest.ITEM_XML,
            Archive.MK_ID(DEFAULT_PATH),
            File.basename(DEFAULT_PATH),
            UMPTG::EPUB::Archive::ArchiveEntry.media_type(entry_name: DEFAULT_PATH)
          )
      n = Nokogiri::XML.parse(item_xml)
      n.document.root['properties'] = "nav"
      return n.document.root.to_s
    end
  end
end
