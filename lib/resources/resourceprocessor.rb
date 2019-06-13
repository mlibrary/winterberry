class ResourceProcessor

  def initialize(p_csv)
    @csv = p_csv
  end

  def find_resources(doc)
    doc.xpath("//*[@class='rb_test' or @class='rbi_test']")
  end

  def get_resource_pathOLD(resource_marker_node)
    str = resource_marker_node.xpath(".//comment()")
    str.text.match("file=\"([^\"]+)\"")[1].strip
  end

  def get_resource_path(resource_marker_node)
    comment_list = resource_marker_node.xpath(".//comment()")
    return "" if comment_list == nil or comment_list.count == 0

    res_doc = Nokogiri::XML(comment_list[0])
    return "" if res_doc == nil

    embed_elem = res_doc.xpath("//embed")
    return "" if embed_elem == nil

    src_attr = embed_elem.attribute("src")
    return "" if src_attr == nil

    return src_attr.to_s
  end

  def get_reference_node(resource_marker_node)
    reference_node = resource_marker_node.previous_element
    if reference_node != nil
      # Confirm that the marker path resides within the
      # reference markup.
      path = get_resource_path(resource_marker_node)
      r = ref.xpath(".//*[@*[contains(.,'#{path}')]]")
      if r.count > 0
        if r.count > 1
          puts "Found multiple instances of path in reference markup."
        end
        return reference_node
      end

      puts "Marker path (#{path}) not found within reference markup (#{reference_node})."
    end
  end

  def get_embed_markup(resource_marker_node)
    path = get_resource_path(resource_marker_node)

    row = @csv.find { |row| row['file_name'] == path }
    if row == nil
      puts "Warning: no resource found for path #{path}"
      return
    end

    embed_code = row['embed_code']
    embed_doc = Nokogiri::XML(embed_code)
    embed_doc.root
  end

  def create_embed_container(resource_marker_node)
    embed_markup = get_embed_markup(resource_marker_node)
    if embed_markup != nil
      embed_container = resource_marker_node.document.create_element("div", :class => "enhanced-media-display")
      embed_container.add_child(embed_markup)
      return embed_container
    end
    return nil
  end

  def create_default_container(reference_node)
    default_container = reference_node.document.create_element("div", :class => "default-media-display")
    default_container.add_child(reference_node)
    default_container
  end

  def replace_node(resource_marker_node)
    resource_marker_node.attribute("class") == "rbi_test"
  end
end