module UMPTG::FMetadata::Processors
  class NewgenMarkerProcessor < EntryProcessor
    @@markerselector = nil

    def action_list(args = {})
      name = args[:name]
      content = args[:content]

      @@markerselector = NewgenMarkerSelector.new if @@markerselector.nil?
      args[:selector] = @@markerselector

      alist = super(args)
      alist.each do |action|
        action.process(name: name)
      end
      return alist
    end

    def new_action(args = {})
      action = UMPTG::FMetadata::MarkerAction.new(
          name: args[:name],
          fragment: args[:fragment],

          )
      return action
    end
  end
end
