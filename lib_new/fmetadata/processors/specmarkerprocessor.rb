module UMPTG::FMetadata::Processors

  class SpecMarkerProcessor < EntryProcessor
    @@selector = nil

    def process(args = {})
      epub = args[:epub]
      entry = args[:entry]

      args[:name] = entry.name
      args[:content] = entry.get_input_stream.read

      # Figure are expected to be contained within a <figure> and
      # images within a <img>. Generate a list of XML fragments
      # for these containers.
      @@selector = SpecMarkerSelector.new if @@selector.nil?
      args[:selector] = @@selector

      action_list = super(args)
      action_list.each do |action|
        action.process()
      end
      return action_list
    end

    def new_action(args = {})
      action = UMPTG::FMetadata::MarkerAction.new(
          epub_file: args[:epub_file],
          entry_name: args[:entry_name],
          fragment: args[:fragment]
          )
      return action
    end
  end
end
