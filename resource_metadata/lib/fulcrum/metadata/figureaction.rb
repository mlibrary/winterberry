module UMPTG::Fulcrum::Metadata

  # Class representing actions for resources found within
  # <figure|img> markup.
  class FigureAction < Action

    @@SELECTION_XPATH = <<-SXPATH
    .//*[
    local-name()='img'
    or local-name()='figcaption'
    or local-name()='audio'
    or local-name()='video'
    or @class='caption'
    or @class='figcap'
    or @class='figCap'
    or @class='figCaption'
    or @class='figcap1'
    or @class='figh'
    or @class='fign'
    or @class='image_caption'
    ]
    SXPATH

    def process(args = {})
      olist = []
      case @node.name
      when 'img'
        # Process <img> fragment.
        olist = Action.process_image(@node, args)
      else
        # Must be a <figure> fragment. Process the contained images and captions.
        nodes = @node.xpath(@@SELECTION_XPATH)
        if nodes.count > 0
          # Empty figure elements not expected.
          olist = Action.process_figure(nodes, args)
        end
      end

      olist.each do |o|
        add_info_msg("found reference for resource #{o.resource_name}")
      end

      # Attach the list XML fragment objects processed to this
      # Action and set it status COMPLETED.
      @object_list = olist
      @status = Action.COMPLETED
    end
  end
end
