module UMPTG::EPUB::OEBPS

  class Spine < UMPTG::EPUB::Node

    ITEMREF_TEMPLATE = <<-XMLTEMP
<itemref idref="%s"/>
    XMLTEMP

    def initialize(args = {})
      a = args.clone
      a[:xpath_node] = "//*[local-name()='spine']"
      a[:xpath_children] =
      super(a)

      @manifest = args[:manifest]

      @xpath_children = "./*[local-name()='itemref']"
    end

    def find(args = {})
      itemrefs = []
      manifest_items = @manifest.find(args)
      unless manifest_items.empty?
        item_id = manifest_items.first["id"]
        raise "invalid manifest item ID" if item_id.nil? or item_id.strip.empty?

        itemrefs = children.select {|r| r['idref'] == item_id }
      end
      return itemrefs
    end

    def add(args = {})
      itemrefs = find(args)
      if itemrefs.empty?
        manifest_items = @manifest.find(args)
        unless manifest_items.empty?
          item_id = manifest_items.first["id"]
          raise "invalid manifest item ID" if item_id.nil? or item_id.strip.empty?

          markup = sprintf(ITEMREF_TEMPLATE, item_id)
          itemrefs = obj_node.add_child(markup)
        end
      end
      return itemrefs.first
    end
  end
end
