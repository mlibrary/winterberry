class ResourceLinker < ResourceProcessor

  def get_embed_xml(metadata)
    link = metadata['link']
    link = link.match('^[^\(]+\(\"([^\"]+)\".*') {|m| m[1] }
    "<p><a href=\"#{link}\">2View resource</a></p>"
  end
end
