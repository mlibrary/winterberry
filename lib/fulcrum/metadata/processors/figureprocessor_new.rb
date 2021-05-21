module UMPTG::Fulcrum::Metadata::Processors

  # Class processes <figure|img> references for resources found
  # within XML content.
  class FigureProcessor < EntryProcessor

    def action_list(args = {})
      name = args[:name]

      selectors = UMPTG::Fulcrum::Vendor.selectors(vendor: :default)
      args[:selector_xpath] = selectors[:element]

      action_list = super(args)

      return action_list
    end

    # Instantiate a new Action for the XML fragment of a referenced resource.
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :fragment   XML fragment for Marker to process.
    def new_action(args = {})
      action = UMPTG::Fulcrum::Metadata::FigureAction.new(
          args
=begin
          name: args[:name],
          fragment: args[:fragment],
          reference_node: args[:reference_node]
=end
          )
      return action
    end
  end
end
