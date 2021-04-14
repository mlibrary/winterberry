module UMPTG::EPUB2PDF

  # Class processes <> references for resources found
  # within XML content.
  class PageProcessor < UMPTG::EPUB::EntryProcessor
    @@selector = nil
    @@fragment_processor = nil

    # Select the XML fragments that refer to resources (<figure|img>)
    # to process and create Actions for each fragment.
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :content    Entry XML content
    def action_list(args = {})
      name = args[:name]

      # Images within a <img>. Generate a list of XML fragments
      # for these containers.
      @@selector = UMPTG::Fragment::ContainerSelector.new if @@selector.nil?
      @@selector.containers = [ 'img' ]
      args[:selector] = @@selector

      # Use the default Fragment processor and return the selected fragments.
      @@fragment_processor = UMPTG::Fragment::Processor.new if @@fragment_processor.nil?
      fragments = @@fragment_processor.process(args)

      # For each fragment, generate a processing action.
      alist = []
      fragments.each do |f|
        action = UMPTG::Action.new(
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
  end
end
