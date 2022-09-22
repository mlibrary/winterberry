module UMPTG::Review

  class EntryProcessor < UMPTG::EPUB::EntryProcessor
  
    @@fragment_processor = nil

    def initialize(args = {})
      super(args)
    end

    # Select the XML fragments to process and create Actions for each fragment.
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :content    Entry XML content
    #   :selector   Class that select elements/comments within the XML content
    def action_list(args = {})
      name = args[:name]

      selector = UMPTG::Fragment::ContainerSelector.new
      selector.containers = @properties[:containers]
      args[:selector] = selector

      # Use the default Fragment processor and return the selected fragments.
      @@fragment_processor = UMPTG::Fragment::Processor.new if @@fragment_processor.nil?
      fragments = @@fragment_processor.process(args)

      # For each fragment, generate a processing action.
      alist = []
      fragments.each do |fragment|
        action = new_action(
            name: name,
            fragment: fragment
            )
        alist << action
      end

      # Process each action.
      alist.each do |action|
        action.process(name: name)
      end

      return alist
    end

    # Instantiate a new Action for the XML fragment of a referenced resource.
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :fragment   XML fragment to process.
    def new_action(args = {})
      action = UMPTG::Action.new(
          name: args[:name],
          fragment: args[:fragment]
          )
    end
  end
end
