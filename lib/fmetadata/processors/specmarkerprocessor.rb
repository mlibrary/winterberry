module UMPTG::FMetadata::Processors

  class SpecMarkerProcessor < EntryProcessor
    @@selector = nil

    def action_list(args = {})
      name = args[:name]
      content = args[:content]

      # Figure are expected to be contained within a <figure> and
      # images within a <img>. Generate a list of XML fragments
      # for these containers.
      @@selector = SpecMarkerSelector.new if @@selector.nil?
      args[:selector] = @@selector

      alist = super(args)
      alist.each do |action|
        action.process(name: name)
      end
      return alist
    end

    def new_action(args = {})
      action = UMPTG::FMetadata::MarkerAction.new(
          name: args[:name],
          fragment: args[:fragment]
          )
      return action
    end
  end
end
