module UMPTG::EPUB::OEBPS

  class TOC < UMPTG::EPUB::Node

    TOC_ITEM_XML = <<-NTEMP
<li id="%s"><a href="%s">%s</a></li>
    NTEMP

    def initialize(args = {})
      a = args.clone
      a[:xpath_node] = "//*[local-name()='nav' and @epub:type='toc']"
      a[:xpath_children] = "//*[local-name()='nav' and @epub:type='toc']//*[local-name()='li']"
      super(a)
    end

    def find(args = {})
      entry_name = args[:entry_name]
      raise "invalid entry name" if entry_name.nil? or entry_name.strip.empty?

      toc_items = children.select {|c| !c.xpath(".//*[local-name()='a' and @href='#{entry_name}']").empty? }
      return toc_items
    end

    def add(args = {})
      toc_items = find(args)
      if toc_items.empty?
        entry_name = args[:entry_name]
        e_name = UMPTG::EPUB::Archive.Archive.MK_PATH(@archive_entry, entry_name)

        entry = @archive_entry.archive.find(entry_name: entry_name)
        title_node = entry.document.xpath("//*[local-name()='head']/*[local-name()='title']").first
        title = title_node.nil? ? e_name : title_node.text

        toc_id = "toc_" + entry_name.gsub(/[ \/\.\,\-]+/, '_')
        markup = sprintf(TOC_ITEM_XML, toc_id, e_name, title)
        list_node = obj_node.xpath(".//*[local-name()='ol' or local-name()='ul']").first
        raise "missing list node" if list_node.nil?
        toc_items = list_node.add_child(markup)
      end
      return toc_items.first
    end
  end
end
