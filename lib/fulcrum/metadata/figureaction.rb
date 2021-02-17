module UMPTG::Fulcrum::Metadata

  # Class representing actions for resources found within
  # <figure|img> markup.
  class FigureAction < Action
    def process(args = {})
      olist = []
      case @fragment.node.name
      when 'img'
        # Process <img> fragment.
        olist = Action.process_image(fragment, args)
      else
        # Must be a <figure> fragment. Process the contained images and captions.
        nodes = fragment.node.xpath(".//*[local-name()='img' or local-name()='figcaption' or @class='figcap' or @class='figh']")
        if nodes.count > 0
          # Empty figure elements not expected.
          olist = Action.process_figure(nodes, args)
        end
      end

      # Attach the list XML fragment objects processed to this
      # Action and set it status COMPLETED.
      @object_list = olist
      @status = Action.COMPLETED
    end
  end
end
