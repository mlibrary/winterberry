module UMPTG::FMetadata::Processors

  # Class processes <figure|img> references for resources found
  # within XML content.
  class FigureProcessor < EntryProcessor

    # Instantiate a new Action for the XML fragment of a referenced resource.
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :fragment   XML fragment for Marker to process.
    def new_action(args = {})
      action = UMPTG::FMetadata::FigureAction.new(
          name: args[:name],
          fragment: args[:fragment]
          )
      return action
    end
  end
end
