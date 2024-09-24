module UMPTG::EPUB::Archive::OEBPS

  class Manifest < UMPTG::EPUB::Archive::Node

    ITEM_XML = <<-XMLTEMP
<item id="%s" href="%s" media-type="%s"/>
    XMLTEMP

    def initialize(args = {})
      a = args.clone
      a[:xpath_node] = "//*[local-name()='manifest']"
      super(a)

      @xpath_children = "./*[local-name()='item']"
    end

    def find(args = {})
      entry_id = args[:entry_id] || ""
      entry_ids = args[:entry_ids] || []
      entry_name = args[:entry_name] || ""
      entry_media_type = args[:entry_mediatype] || ""
      entry_properties = args[:entry_properties] || ""

      xpath_args = ["local-name()='item'"]

      xpath_args << "@id='#{entry_id.strip}'" \
              unless entry_id.strip.empty? or !entry_ids.empty?
      xpath_id_args = entry_ids.collect {|id| "@id='#{id}'" }
      xpath_args << "(#{xpath_id_args.join(' or ')})" unless xpath_id_args.empty?

      xpath_args << "@href='#{UMPTG::EPUB::Archive::Files.MK_PATH(@files_entry, entry_name.strip)}'" \
                unless entry_name.strip.empty?
      xpath_args << "@media-type='#{entry_media_type.strip}'" unless entry_media_type.strip.empty?

      p_path = ""
      unless entry_properties.nil?
        entry_properties.strip!
        p_list = entry_properties.split(" ").collect {|p| "contains(concat(' ',@properties,' '),' #{p} ')" }
        xpath_args << "(" + p_list.join(' or ') + ")" unless p_list.empty?
      end
      xpath = "./*[" + xpath_args.join(' and ') + "]"
      return obj_node.xpath(xpath)
    end

    def add(args = {})
      entry = @files_entry.files.add(args)

      entry_id = args[:entry_id]
      entry_id = Archive.MK_ID(entry.name) if entry_id.nil? or entry_id.strip.empty?
      entry_properties = args[:entry_properties]

      markup = sprintf(ITEM_XML, entry_id, Archive.MK_PATH(@files_entry, entry.name), entry.media_type.to_s)
      item_node = obj_node.add_child(markup).first

      item_node['properties'] = entry_properties unless entry_properties.nil? or entry_properties.strip.empty?
      return entry
    end

    def navigation(args = {})
      return find(entry_properties: "nav").first
    end

    def entries(args = {})
      items = find(args)
      e_list = items.collect {|n|
          @rendition.epub.files.find(entry_name: Manifest.MK_PATH(@files_entry, n['href'])).first
        }
    end

    def self.MK_PATH(file_entry, entry_name)
      m = File.expand_path(file_entry.name)
      p = m.delete_suffix(file_entry.name)
      n = File.expand_path(entry_name, File.dirname(m))
      r = n.delete_prefix(p)
      return r
    end

    def self.ITEM_XML
      return ITEM_XML
    end
  end
end
