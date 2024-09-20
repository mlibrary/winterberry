module UMPTG::EPUB

  class Spine < UMPTG::Object

    ITEMREF_TEMPLATE = <<-XMLTEMP
<itemref idref="%s"/>
    XMLTEMP

    def initialize(args = {})
      super(args)

      @rendition = args[:rendition]
      raise "missing rendition entry for spine" if @rendition.nil?
    end

    def spine_node
      spine_node = @rendition.opf_entry.document.xpath("//*[local-name()='spine']").first
      raise "missing spine element" if spine_node.nil?
      return spine_node
    end

    def find_itemref_nodelist(args = {})
      itemref_nodelist = []
      item_nodelist = @rendition.manifest.find_item_nodelist(args)
      unless item_nodelist.empty?
        item_id = item_nodelist.first["id"]
        raise "invalid manifest item ID" if item_id.nil? or item_id.strip.empty?

        xpath = "./*[local-name()='itemref' and @idref='#{item_id}']"
        itemref_nodelist = spine_node.xpath(xpath)
      end
      return itemref_nodelist
    end

    def add_itemref_node(args = {})
      itemref_nodelist = find_itemref_nodelist(args)
      if itemref_nodelist.empty?
        item_nodelist = @rendition.manifest.find_item_nodelist(args)
        unless item_nodelist.empty?
          item_id = item_nodelist.first["id"]
          raise "invalid manifest item ID" if item_id.nil? or item_id.strip.empty?

          markup = sprintf(ITEMREF_TEMPLATE, item_id)
          itemref_nodelist = spine_node.add_child(markup)
        end
      end
      return itemref_nodelist.first
    end

    def add(args = {})
      itemref_node = add_itemref_node(args)
      entry = @rendition.opf_entry.archive.find(args)
      raise "no entry for #{itemref_node['idref']}" if entry.nil?
      return entry
    end
  end
end
