class PressResourceLocator < ResourceLocator

  def find_resources(doc)
    doc.xpath("//*[@class='rb_test' or @class='rbi_test']")
  end

  def get_resource_path(resource_marker_node)
    str = resource_marker_node.xpath(".//comment()")
    #str.text.match("file=\"([^\"]+)\"")[1].strip
    str.text.match("<img>([^\"]+)</img>")[1].strip
  end

  def get_resource_pathXML(resource_marker_node)
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
      r = reference_node.xpath(".//*[@*[contains(.,'#{path}')]]")
      if r.count > 0
        if r.count > 1
          puts "Found multiple instances of path in reference markup."
        end
        return reference_node
      end

      puts "Marker path (#{path}) not found within reference markup (#{reference_node})."
    end
  end

  def replace_node(resource_marker_node)
    klass_attr = resource_marker_node.attribute("class")
    klass = klass_attr == nil ? "" : klass_attr.value
    klass == "rbi_test"
  end
end
