module UMPTG::Review

  class NormalizeInsertMarkupAction < NormalizeFigureAction

    def process(args = {})
      super(args)

      reference_node = @properties[:reference_node]
      markup = @properties[:markup]

      unless markup.empty?
        #fragment = Nokogiri::XML::DocumentFragment.parse(markup)
        fragment = reference_node.document.parse(markup)
        reference_node.add_next_sibling(fragment)

        add_info_msg("#{reference_node.name}: inserted next sibling markup #{markup}.")

        @status = NormalizeAction.NORMALIZED
      end
    end
  end
end
