module UMPTG::FMetadata::Processors

  class EntryProcessor < UMPTG::EPUB::EntryProcessor
  
    @@fragment_processor = nil

    def action_list(args = {})
      name = args[:name]
      content = args[:content]

      @@fragment_processor = UMPTG::Fragment::Processor.new if @@fragment_processor.nil?
      fragments = @@fragment_processor.process(args)

      alist = []
      fragments.each do |f|
        action = new_action(
            name: name,
            fragment: f
            )
        alist << action
      end

      return alist
    end

    def new_action(args = {})
      action = UMPTG::FMetadata::Action.new(
          name: args[:name],
          fragment: args[:fragment]
          )
    end
  end
end
