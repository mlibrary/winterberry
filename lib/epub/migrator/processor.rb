module UMPTG::EPUB::Migrator

  class << self
    def NCXFilter(args = {})
      return Filter::NCXFilter.new(args)
    end

    def OPFFilter(args = {})
      return Filter::OPFFilter.new(args)
    end

    def XHTMLFilter(args = {})
      return Filter::XHTMLFilter.new(args)
    end

TOC_HTML = <<-THTML
<?xml version="1.0" encoding="UTF-8"?>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
<head>
<meta content="initial-scale=1.0,maximum-scale=5.0" name="viewport"/>
<title></title>
</head>
<body>
<nav id="nav_toc" role="doc-toc" epub:type="toc" aria-labelledby="ncx-head">
<h2 id="ncx-head"></h2>
<ol>
</ol>
</nav>
</body>
</html>
THTML

    # Update reference path extension from .htm|.html to .xhtml.
    # Required for EPUB 3.x
    def fix_ext(path)
      path = path.nil? ? "" : path
      unless path.empty? or path.start_with?("http:") or path.include?("www.")
        slist = path.split('#')
        p = slist[0]
        suf = slist.count > 1 ? "#" + slist[1] : ""

        ext = File.extname(p)
        if [".htm", ".html", ".xml"].include?(ext)
          return File.join(File.dirname(p), File.basename(p, ".*") + ".xhtml" + suf)
        end
      end
      return path
    end

    # Convert a NCX TOC to a HTML TOC.
    def ncx_to_xhtml(ncx_doc)
      toc_doc = Nokogiri::XML.parse(TOC_HTML)

      ncx_title_node = ncx_doc.xpath("//*[local-name()='docTitle']/*[local-name()='text']").first

      toc_headtitle_node = toc_doc.xpath("//*[local-name()='head']/*[local-name()='title']").first
      raise "TOC head/title not found" if toc_headtitle_node.nil?
      toc_headtitle_node.content = ncx_title_node.content

      toc_nav_node = toc_doc.xpath("//*[local-name()='nav']").first
      raise "TOC nav not found" if toc_nav_node.nil?

      toc_ol_node = toc_nav_node.xpath("./*[local-name()='ol']").first
      raise "TOC nav/ol not found" if toc_ol_node.nil?

      ncx_title_node = ncx_doc.xpath("//*[local-name()='docTitle']/*[local-name()='text']").first
      toc_title_node = toc_nav_node.xpath("./*[local-name()='h2']").first
      raise "TOC nav/title not found" if toc_title_node.nil?

      toc_title_node.content = ncx_title_node.content

      ncx_doc.xpath("//*[local-name()='navPoint']").each do |ncx_node|
        id = ncx_node["id"]
        title = ncx_node.xpath("./*[local-name()='navLabel']/*[local-name()='text']").first.content
        href = ncx_node.xpath("./*[local-name()='content']").first["src"]

        markup = "<li id=\"#{id}\"><a href=\"#{href}\">#{title}</a></li>"
        toc_ol_node.add_child(markup)
      end
      return toc_doc
    end
  end

  class Processor < UMPTG::XML::Pipeline::Processor
    def initialize(args = {})
      args[:filters] = FILTERS
      super(args)
    end
  end
end
