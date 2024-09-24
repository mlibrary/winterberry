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

    def select(node, args = {})
      return node['idref'] == args[:entry_idref] \
            unless args[:entry_idref].nil?
      return true
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

    def entries(args = {})
      items = items(args)
      return items.collect {|n|
          @rendition.epub.archive.find(entry_name: Manifest.MK_PATH(@archive_entry, n['href'])).first
        }
    end

    def items(args = {})
      spine_item_ids = find(args).collect {|n| n["idref"] }
      return @rendition.manifest.find(entry_ids: spine_item_ids)
    end
  end
end
