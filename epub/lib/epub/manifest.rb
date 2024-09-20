module UMPTG::EPUB

  class Manifest < UMPTG::Object

    ITEM_TEMPLATE = <<-XMLTEMP
<item id="%s" href="%s" media-type="%s"/>
    XMLTEMP

    def initialize(args = {})
      super(args)

      @rendition = args[:rendition]
      raise "missing rendition for manifest" if @rendition.nil?

    end

    def manifest_node
      manifest_node = @rendition.opf_entry.document.xpath("//*[local-name()='manifest']").first
      raise "missing manifest element" if manifest_node.nil?
      return manifest_node
    end

    def navigation(args = {})
      return find(entry_properties: "nav")
    end

    def find_item_nodelist(args = {})
      entry_id = args[:entry_id]
      entry_name = args[:entry_name]
      entry_media_type = args[:entry_mediatype]
      entry_properties = args[:entry_properties]

      xpath_args = ["local-name()='item'"]
      xpath_args << "@id='#{entry_id.strip}'" unless entry_id.nil? or entry_id.strip.empty?
      xpath_args << "@href='#{ename(entry_name.strip)}'" unless entry_name.nil? or entry_name.strip.empty?
      xpath_args << "@media-type='#{entry_media_type.strip}'" unless entry_media_type.nil? or entry_media_type.strip.empty?

      p_path = ""
      unless entry_properties.nil?
        entry_properties.strip!
        p_list = entry_properties.split(" ").collect {|p| "contains(concat(' ',@properties,' '),' #{p} ')" }
        xpath_args << "(" + p_list.join(' or ') + ")" unless p_list.empty?
      end
      xpath = "./*[" + xpath_args.join(' and ') + "]"
      item_nodelist = manifest_node.xpath(xpath)
      return item_nodelist
    end

    def find(args = {})
      item_nodelist = find_item_nodelist(args)
      entry_list = item_nodelist.collect {|n| @opf_entry.archive.find(entry_name: n["href"]) }
      return entry_list.first
    end

    def add_item_node(args = {})
      entry = @rendition.opf_entry.archive.add(args)

      #m = File.expand_path(@rendition.opf_entry.name)
      #n = File.expand_path(entry.name)
      entry_id = args[:entry_id]
      entry_id = "item_" + entry.name.gsub(/[ \/\.\,\-]+/, '_') if entry_id.nil? or entry_id.strip.empty?
      entry_properties = args[:entry_properties]

      markup = sprintf(ITEM_TEMPLATE, entry_id, ename(entry.name), entry.media_type.to_s)
      n = manifest_node.add_child(markup).first
      n['properties'] = entry_properties unless entry_properties.nil? or entry_properties.strip.empty?
      return n
    end

    def add(args = {})
      item_node = add_item_node(args)
      entry = @rendition.opf_entry.archive.find(args)
      raise "no entry for #{item_node['href']}" if entry.nil?
      return entry
    end

    private

    def ename(entry_name)
      m = File.expand_path(@rendition.opf_entry.name)
      n = File.expand_path(entry_name)
      return n.delete_prefix(File.dirname(m)+"/")
    end
  end
end
