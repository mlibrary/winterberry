module UMPTG::Fulcrum::Metadata

  # Class representing actions for resources found within
  # <figure|img> markup.
  class FigureAction < Action

  @@SELECTION_XPATH = <<-SXPATH
  .//*[
  local-name()='img'
  or local-name()='figcaption'
  or @class='figcap'
  or @class='figcap1'
  or @class='figh'
  or @class='image_caption'
  ]
  SXPATH
  @@SELECTION_XPATH2 = <<-SXPATH2
  ./ancestor::*[local-name()='figure'][1]
  SXPATH2

    def process(args = {})
      ref_node = @properties[:reference_node]

      # Determine whether the image has a caption.
      # First locate the figure container, vendor specific.
      container_node_list = ref_node.xpath(@@SELECTION_XPATH2)
      if container_node_list.empty?
        # Process <img> fragment.
        olist = Action.process_image(ref_node, name: @properties[:name])
      else
        # Must be a <figure> fragment. Process the contained images and captions.
        container_node = container_node_list.first
        node_list = container_node.xpath(@@SELECTION_XPATH)
        unless node_list.empty?
          # Empty figure elements not expected.
          olist = Action.process_figure(node_list, name: @properties[:name])
        end
      end

=begin
      case @fragment.node.name
      when 'img'
        # Process <img> fragment.
        olist = Action.process_image(fragment, args)
      else
        # Must be a <figure> fragment. Process the contained images and captions.
        nodes = fragment.node.xpath(@@SELECTION_XPATH)
        if nodes.count > 0
          # Empty figure elements not expected.
          olist = Action.process_figure(nodes, args)
        end
      end
=end

      # Attach the list XML fragment objects processed to this
      # Action and set it status COMPLETED.
      @object_list = olist
      @status = Action.COMPLETED
    end
  end
end
