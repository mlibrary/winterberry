module UMPTG::FMetadata::Processors

  class SpecFigureProcessor < FigureProcessor
    @@selector = nil

    def process(args = {})
      epub = args[:epub]
      entry = args[:entry]

      args[:name] = entry.name
      args[:content] = entry.get_input_stream.read

      # Figure are expected to be contained within a <figure> and
      # images within a <img>. Generate a list of XML fragments
      # for these containers.
      @@selector = UMPTG::Fragment::ContainerSelector.new if @@selector.nil?
      @@selector.containers = [ 'img', 'figure' ]
      args[:selector] = @@selector

      action_list = super(args)
      action_list.each do |action|
        action.process(name: entry.name)
      end
      return action_list
    end
  end
end
