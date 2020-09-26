module UMPTG::Resources

  class EmbedMapAction < Action
    def process()
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

      emb_fragment = embed_fragment()
      if emb_fragment == nil
        @status = Action.FAILED
        return
      end

      iframe_node = emb_fragment.xpath(".//*[local-name()='iframe']").first
      if iframe_node.nil?
        @status = Action.FAILED
        @message = "Error: no iframe found within embed markup for resource #{reference_action_def.reference_name}."
        return
      end

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

      figure_node['data-resource-type'] = 'interactive-map'
      figure_node['data-href'] = data_href
      figure_node['data-title'] = data_title

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

      @status = Action.COMPLETED
    end
  end
end
