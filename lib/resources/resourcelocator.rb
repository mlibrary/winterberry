class ResourceLocator
  def find_resources(doc)
    return doc.xpath("//*[@class='fig' or @class='rb']")
  end

  def is_marker?(node)
    klass_attr = node.attribute("class")
    klass = klass_attr == nil ? "" : klass_attr.value
    klass == "rb"
  end

  def resource_name_from_marker(resource_node)
    str = resource_node.xpath(".//comment()")
    str.text.strip
    #str.text.match("<img>([^\"]+)</img>")[1].strip
  end

  def default_container(doc)
    doc.create_element("div", :class => "default-media-display")
  end

  def embed_markup(embed_str)
    markup = "<div class=\"enhanced-media-display\">#{embed_str}</div>"
  end

  def find_caption(img_node)
    klass_attr = img_node.next_element.attribute("class") unless img_node.next_element == nil
    klass = klass_attr.value unless klass_attr == nil

    img_node.next_element if klass == 'image_caption'
  end

  def caption_markup(link, title = nil, caption_node = nil)
    title = "View resource." if title == nil
    cmark = "<span class=\"enhanced-media-display\"><a href=\"#{link}\" target=\"_blank\">#{title}</a></span>"
    markup = caption_node == nil ?
          "<p class=\"image_caption\">#{cmark}</p>" : cmark
    fragment = Nokogiri::XML.fragment(markup)
  end
end