module UMPTG::EPUB

  class Navigation < UMPTG::Object
    attr_reader :rendition

    NAVIGATION_PATH = File.join("OEBPS", "navigation.xhtml")

    NAVIGATION_XML = <<-NTEMP
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
      @entry = args[:entry]

      @toc = nil
    end

    def aentry
      @entry = @rendition.manifest.add(
            entry_name: NAVIGATION_PATH,
            entry_content: NAVIGATION_XML,
            entry_properties: "nav"
          ) if @entry.nil?
      return @entry
    end

    def toc
      @toc = TOC.new(rendition: self) if @toc.nil?
      return @toc
    end
  end
end
