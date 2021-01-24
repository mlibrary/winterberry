module UMPTG::FMetadata::Processors

  class EntryProcessor < UMPTG::EPUB::EntryProcessor
  
    @@fragment_processor = nil
    
    def initialize(args = {})
      super(args)
    end
    
    def process(args = {})
      epub = args[:epub]
      entry = args[:entry]

      @@fragment_processor = UMPTG::Fragment::Processor.new if @@fragment_processor.nil?
      fragments = @@fragment_processor.process(args)

      action_list = []
      fragments.each do |f|
        action = new_action(
            epub_file: epub.epub_file,
            entry_name: entry.name,
            fragment: f
            )
        action_list << action
      end

      return action_list
    end

    def new_action(args = {})
      action = UMPTG::FMetadata::Action.new(
          epub_file: args[:epub_file],
          entry_name: args[:entry_name],
          fragment: args[:fragment]
          )
    end
  end
end
