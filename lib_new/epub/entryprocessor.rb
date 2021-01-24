module UMPTG::EPUB
  class EntryProcessor < UMPTG::Object
    def initialize(args = {})
      super(args)
    end

    # This must be overridden. The base method does nothing.
    def process(args = {})
      epub = args[:epub]
      entry = args[:entry]

      action_list = []
      action = UMPTG::Action.new(
            epub_file: epub.epub_file,
            entry_name: entry.name
            )
      #action.process()
      action_list << action

      return action_list
    end
  end
end
