module UMPTG::Fulcrum::Metadata::Processors

  # Class processes <figure|img> references for resources found
  # within XML content.
  class SpecFigureProcessor < FigureProcessor
    @@selector = nil

    # Select the XML fragments that refer to resources (<figure|img>)
    # to process and create Actions for each fragment.
    #
    # Arguments:
    #   :name       Content identifier, e.g. EPUB entry name or file name.
    #   :content    Entry XML content
    def action_list(args = {})
      name = args[:name]

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
