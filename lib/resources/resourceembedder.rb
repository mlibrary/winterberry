class ResourceEmbedder < ResourceProcessor

  def get_embed_xml(metadata)
    metadata['embed_code']
  end
end