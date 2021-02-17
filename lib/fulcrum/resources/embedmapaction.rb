module UMPTG::Fulcrum::Resources

  # Class that inserts resource embed viewer markup into
  # XML content (interactive map).
  class EmbedMapAction < Action
    def process()
      # Locate the <figure> within the XML content.
      figure_node = reference_container
      loop do
        if figure_node.nil?
          @status = Action.FAILED
          @message = "Error: no figure element wrapping interactive map for resource #{reference_action_def.reference_name}."
          return
        end
        break if figure_node.name == 'figure'
        figure_node = figure_node.parent
      end

      # Retrieve the resource embed interactive markup from the
      # Fulcrum resource metadata.
      emb_fragment = embed_fragment()
      if emb_fragment == nil
        @status = Action.FAILED
        return
      end

      # Search within the interactive map markup for the <iframe>.
      iframe_node = emb_fragment.xpath(".//*[local-name()='iframe']").first
      if iframe_node.nil?
        @status = Action.FAILED
        @message = "Error: no iframe found within embed markup for resource #{reference_action_def.reference_name}."
        return
      end

      # From the <iframe>, retrieve the map @src and @title values.
      data_href = iframe_node['src']
      if data_href.nil? or data_href.empty?
        @status = Action.FAILED
        @message = "Error: no iframe/@src value found for resource #{reference_action_def.reference_name}."
        return
      end
      data_title = iframe_node['title']
      if data_title.nil? or data_title.empty?
        @message = "Error: no iframe/@src value found for resource #{reference_action_def.reference_name}."
      end

      # On the <figure>, add the @data-{}resource-type,href,title} values.
      figure_node['data-resource-type'] = 'interactive-map'
      figure_node['data-href'] = data_href
      figure_node['data-title'] = data_title

      # Determine if the <figure> contains a caption. If so, append
      # a note concerning the Fulcrum edition.
      caption = Action.find_caption(figure_node)
      unless caption.nil? or caption.empty?
        markup = '<p class="CAP" data-resource-trigger="modal">An interactive version can be found in the Fulcrum edition.</p>'
        fragment = Nokogiri::XML::DocumentFragment.parse(markup)
        cp = caption.last
        if cp.name.downcase == 'p'
          cp.add_next_sibling(fragment)
        else
          cp.add_child(fragment)
        end
      end

      # Action completed.
      @status = Action.COMPLETED
    end
  end
end
