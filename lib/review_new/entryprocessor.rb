module UMPTG::Review

  class EntryProcessor < UMPTG::EPUB::EntryProcessor
  
    @@fragment_processor = nil

    def initialize(args = {})
      super(args)

      @logger = @properties[:logger]

      @selector = @properties[:selector]
      if @selector.nil?
        @selector = ElementSelector.new(args)
      end
    end

    # Select the XML fragments to process and create Actions for each fragment.
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :content    Entry XML content
    #   :selector   Class that select elements/comments within the XML content
    def action_list(args = {})
      name = args[:name]
      xml_doc = args[:xml_doc]

      reference_action_list = []
      unless @selector.nil? or xml_doc.nil?

        reference_list = @selector.references(xml_doc)

        # For each reference element, determine the necessary actions.
        reference_list.each do |refnode|
          reference_action_list += new_action(
                    name: name,
                    reference_node: refnode
                  )
        end

        # Process all the Actions for this XML content.
        reference_action_list.each do |action|
          action.process()
        end
      end

      # Return the list of Actions which contains the status
      # for each.
      return reference_action_list
    end

    # Instantiate a new Action for the XML fragment of a referenced resource.
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :fragment   XML fragment to process.
    def new_action(args = {})
      return [
            Action.new(args)
          ]
    end
  end
end
