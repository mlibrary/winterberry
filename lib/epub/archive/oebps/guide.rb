module UMPTG::EPUB::Archive::OEBPS

  class Guide < UMPTG::EPUB::Archive::Node

    ITEM_XML = <<-XMLTEMP
<reference id="%s" href="%s" type="%s" title="%s"/>
    XMLTEMP

    def initialize(args = {})
      a = args.clone
      a[:xpath_node] = "//*[local-name()='guide']"
      super(a)

      @xpath_children = "./*[local-name()='reference']"
    end

    def find(args = {})
      return [] if obj_node.nil?

      entry_id = args[:entry_id] || ""
      entry_ids = args[:entry_ids] || []
      entry_name = args[:entry_name] || ""
      entry_media_type = args[:entry_mediatype] || ""

      xpath_args = ["local-name()='reference'"]

      xpath_args << "@id='#{entry_id.strip}'" \
              unless entry_id.strip.empty? or !entry_ids.empty?
      xpath_id_args = entry_ids.collect {|id| "@id='#{id}'" }
      xpath_args << "(#{xpath_id_args.join(' or ')})" unless xpath_id_args.empty?

      xpath_args << "@href='#{UMPTG::EPUB::Archive::Files.MK_PATH(@files_entry, entry_name.strip)}'" \
                unless entry_name.strip.empty?
      xpath = "./*[" + xpath_args.join(' and ') + "]"
      return obj_node.xpath(xpath)
    end

    def add(args = {})
      entry_id = args[:entry_id]
      entry_id = UMPTG::EPUB::Archive::Files.MK_ID(entry.name) if entry_id.nil? or entry_id.strip.empty?
      entry_name = args[:entry_name] || ""
      entry_type = args[:entry_type] || ""
      entry_title = args[:entry_type] || ""

      markup = sprintf(ITEM_XML, entry_id, UMPTG::EPUB::Archive::Files.MK_PATH(@files_entry, entry.name), entry_type, entry_title)
      item_node = obj_node.add_child(markup).first
      return entry
    end

    def rename(args = {})
      item_node = find(args).first
      item_new_name = UMPTG::EPUB::Archive::Files.MK_PATH(@files_entry, args[:entry_new_name])
      item_node["href"] = item_new_name unless item_node.nil?
      return item_node
    end

    def self.ITEM_XML
      return ITEM_XML
    end
  end
end
