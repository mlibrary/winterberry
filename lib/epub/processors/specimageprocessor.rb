module UMPTG::EPUB::Processors
  class SpecImageProcessor < UMPTG::EPUB::Processors::ImageProcessor
    @@imgselector = nil

    def process(args = {})
      @@imgselector = UMPTG::Fragment::ContainerSelector.new if @@imgselector.nil?
      @@imgselector.containers = [ 'img', 'figure' ]
      args[:selector] = @@imgselector

      fragments = super(args)

      @img_list += UMPTG::EPUB::Processors::ImageProcessor::process_images(fragments, args)
      fragments.each do |fragment|
        unless fragment.node.name == 'img'
          # Must be a figure fragment. Process the images and captions.
          nodes = fragment.node.xpath(".//*[local-name()='img' or local-name()='figcaption' or @class='figcap' or @class='figh']")
          if nodes.count > 0
            # Empty figure elements ot expected.
            @img_list += UMPTG::EPUB::Processors::ImageProcessor::process_figures(nodes, args)
          end
        end
      end
      return fragments
    end
  end
end
