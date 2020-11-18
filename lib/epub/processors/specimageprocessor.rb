module UMPTG::EPUB::Processors

  # Process an EPUB that conforms to our EPUB specification.
  class SpecImageProcessor < UMPTG::EPUB::Processors::ImageProcessor
    @@imgselector = nil

    def process(args = {})
      # Figure are expected to be contained within a <figure> and
      # images within a <img>. Generate a list of XML fragments
      # for these containers.
      @@imgselector = UMPTG::Fragment::ContainerSelector.new if @@imgselector.nil?
      @@imgselector.containers = [ 'img', 'figure' ]
      args[:selector] = @@imgselector

      fragments = super(args)

      fragments.each do |fragment|
        case fragment.node.name
        when 'img'
          # Process <img> fragment.
          @img_list += UMPTG::EPUB::Processors::ImageProcessor.process_image(fragment, args)
        else
          # Must be a <figure> fragment. Process the contained images and captions.
          nodes = fragment.node.xpath(".//*[local-name()='img' or local-name()='figcaption' or @class='figcap' or @class='figh']")
          if nodes.count > 0
            # Empty figure elements not expected.
            @img_list += UMPTG::EPUB::Processors::ImageProcessor.process_figure(nodes, args)
          end
        end
      end
      return fragments
    end
  end
end
