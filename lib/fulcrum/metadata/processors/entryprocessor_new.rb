module UMPTG::Fulcrum::Metadata::Processors

  class EntryProcessor < UMPTG::EPUB::EntryProcessor

    # Select the XML fragments to process and create Actions for each fragment.
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :content    Entry XML content
    #   :selector   Class that select elements/comments within the XML content
    def action_list(args = {})
      name = args[:name]

      xml_doc = args[:xml_doc]
      selector_xpath = args[:selector_xpath]

      node_list = xml_doc.xpath(selector_xpath)
      action_list = node_list.collect do |n|
        new_action(
            name:name,
            reference_node: n
          )
      end

      # Process each action.
      action_list.each do |action|
        action.process()
      end
      return action_list
    end
=begin
    def action_list(args = {})
      name = args[:name]

      # Use the default Fragment processor and return the selected fragments.
      @@fragment_processor = UMPTG::Fragment::Processor.new if @@fragment_processor.nil?
      fragments = @@fragment_processor.process(args)

      # For each fragment, generate a processing action.
      alist = []
      fragments.each do |f|
        action = new_action(
            name: name,
            fragment: f
            )
        alist << action
      end

      # Process each action.
      alist.each do |action|
        action.process(name: name)
      end

      return alist
    end
=end

    # Instantiate a new Action for the XML fragment of a referenced resource.
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :fragment   XML fragment to process.
    def new_action(args = {})
      action = UMPTG::Fulcrum::Metadata::Action.new(
          name: args[:name],
          fragment: args[:fragment]
          )
    end
  end
end
