module UMPTG::Fulcrum::Metadata::Processors

  # Class processes references for additional resources found
  # within XML content produced by vendor Newgen.
  class NewgenMarkerProcessor < EntryProcessor
    @@markerselector = nil

    # Select the XML fragments that refer to additional resources (Markers)
    # to process and create Actions for each fragment.
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :content    Entry XML content
    def action_list(args = {})
      name = args[:name]

      # Generate and perform necessary Actions for the
      # selected, referenced additional resources.
      @@markerselector = NewgenMarkerSelector.new if @@markerselector.nil?
      args[:selector] = @@markerselector
      alist = super(args)

      return alist
    end

    # Instantiate a new Action for the XML fragment of a referenced
    # additional resource.
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :fragment   XML fragment for Marker to process.
    def new_action(args = {})
      action = UMPTG::Fulcrum::Metadata::MarkerAction.new(
          name: args[:name],
          fragment: args[:fragment],

          )
      return action
    end
  end
end
