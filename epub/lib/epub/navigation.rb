module UMPTG::EPUB

  class Navigation < UMPTG::Object

    NAVIGATION_TEMPLATE = <<-NTEMP
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

    TOC_TEMPLATE  = <<-NTEMP
<li id="%s"><a href="%s">%s</a></li>
    NTEMP

    def initialize(args = {})
      super(args)

      @rendition = args[:rendition]
      raise "missing rendition for navigation" if @rendition.nil?

      @nav_entry = @rendition.manifest.navigation
      if @nav_entry.nil?
        @nav_entry = @rendition.manifest.add(
              entry_name: File.join("OEBPS", "navigation.xhtml"),
              entry_content: NAVIGATION_TEMPLATE,
              entry_properties: "nav"
            )
      end
    end

    def find_toc_nodelist(args = {})
      nav_type_node = find_nav_type_node(args)
      toc_nodelist = []
      if nav_type_node.nil?
      else
        entry_name = args[:entry_name]
        if entry_name.nil? or entry_name.strip.empty?
          xpath = ".//*[local-name()='li']"
        else
          xpath = ".//*[local-name()='a' and @href='#{ename(entry_name)}']/ancestor::*[local-name()='li']"
        end
        toc_nodelist = @nav_entry.document.xpath(xpath)
        return toc_nodelist
      end
    end

    def add(args = {})
      toc_nodelist = find_toc_nodelist(args)
      if toc_nodelist.empty?
        nav_type_node = find_nav_type_node(args)
        list_node = nav_type_node.xpath(".//*[local-name()='ol' or local-name()='ul']").first
        if list_node.nil?
        else
          entry_name = args[:entry_name]
          id = args[:toc_id]
          id = "item_" + entry_name.gsub(/[ \/\.\,\-]+/, '_') if id.nil? or id.strip.empty?
          markup = sprintf(TOC_TEMPLATE, id, ename(entry_name), entry_name)
          list_node.add_child(markup)
        end
      end
    end

    private

    def find_nav_type_node(args = {})
      epub_type = args[:epub_type]
      epub_type = "toc" if epub_type.nil? or epub_type.strip.empty?

      xpath = "//*[local-name()='nav' and @epub:type='#{epub_type}']"
      nav_type_node = @nav_entry.document.xpath(xpath).first
      return nav_type_node
    end

    def ename(entry_name)
      m = File.expand_path(@nav_entry.name)
      n = File.expand_path(entry_name)
      return n.delete_prefix(File.dirname(m)+"/")
    end
  end
end
