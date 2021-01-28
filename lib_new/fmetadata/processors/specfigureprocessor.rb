module UMPTG::FMetadata::Processors

  class SpecFigureProcessor < FigureProcessor
    @@selector = nil

    def action_list(args = {})
      name = args[:name]
      content = args[:content]

      # Figure are expected to be contained within a <figure> and
      # images within a <img>. Generate a list of XML fragments
      # for these containers.
      @@selector = UMPTG::Fragment::ContainerSelector.new if @@selector.nil?
      @@selector.containers = [ 'img', 'figure' ]
      args[:selector] = @@selector

      alist = super(args)
      alist.each do |action|
        action.process(name: name)
      end
      return alist
    end
  end
end
