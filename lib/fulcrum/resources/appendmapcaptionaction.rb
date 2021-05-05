module UMPTG::Fulcrum::Resources

  # Class that inserts resource embed viewer markup into
  # XML content (interactive map).
  class AppendMapCaptionAction < Action
    def process()
=begin
      # Determine if the <figure> contains a caption. If so, append
      # a note concerning the Fulcrum edition.
      caption = Action.find_caption(figure_node)
=end
      markup = '<p class="CAP" data-resource-trigger="modal">An interactive version can be found in the Fulcrum edition.</p>'
      fragment = Nokogiri::XML::DocumentFragment.parse(markup)
      if reference_node.name.downcase == 'p'
        reference_node.add_next_sibling(fragment)
      else
        reference_node.add_child(fragment)
      end

      # Action completed.
      @status = Action.COMPLETED
    end
  end
end
