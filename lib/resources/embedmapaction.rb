class EmbedMapAction < Action
  def process()
    resource = @action_args[:resource]
    resource_metadata = @action_args[:resource_metadata]
    resource_node = resource.resource_node

    loop do
      if resource_node.nil?
        @status = @@FAILED
        @message = "Error: no figure element wrapping interactive map for resource #{resource_metadata['file_name']}."
        return
      end
      break if resource_node.name == 'figure'
      resource_node = resource_node.parent
    end

    emb_fragment = embed_fragment()
    if emb_fragment == nil
      @status = @@FAILED
      return
    end

    iframe_node = emb_fragment.xpath(".//*[local-name()='iframe']").first
    if iframe_node.nil?
      @status = @@FAILED
      @message = "Error: no iframe found within embed markup for resource #{resource_metadata['file_name']}."
      return
    end

    data_href = iframe_node['src']
    if data_href.nil? or data_href.empty?
      @status = @@FAILED
      @message = "Error: no iframe/@src value found for resource #{resource_metadata['file_name']}."
      return
    end

    data_title = iframe_node['title']
    if data_title.nil? or data_title.empty?
      @message = "Error: no iframe/@src value found for resource #{resource_metadata['file_name']}."
    end

    resource_node['data-resource-type'] = 'interactive-map'
    resource_node['data-href'] = data_href
    resource_node['data-title'] = data_title

    caption = Action.find_caption(resource_node)
    unless caption.nil? or caption.empty?
      markup = '<p class="CAP" data-resource-trigger="modal">An interactive version can be found in the Fulcrum edition.</p>'
      fragment = Nokogiri::XML::DocumentFragment.parse(markup)
      caption.last.add_child(fragment)
    end

    @status = @@COMPLETED
  end

  def to_s
    element_action_to_s
  end
end