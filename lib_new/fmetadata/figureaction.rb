module UMPTG::FMetadata
  class FigureAction < Action
    def process(args = {})
      olist = []
      case @fragment.node.name
      when 'img'
        # Process <img> fragment.
        olist = UMPTG::FMetadata::Processors::FigureProcessor.process_image(fragment, args)
      else
        # Must be a <figure> fragment. Process the contained images and captions.
        nodes = fragment.node.xpath(".//*[local-name()='img' or local-name()='figcaption' or @class='figcap' or @class='figh']")
        if nodes.count > 0
          # Empty figure elements not expected.
          olist = UMPTG::FMetadata::Processors::FigureProcessor.process_figure(nodes, args)
        end
      end

      @object_list = olist
      @status = Action.COMPLETED
    end
  end
end
