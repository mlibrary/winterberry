module UMPTG::Fulcrum::Metadata

  # Class is the base for resource metadata processing.
  class Action < UMPTG::XML::Pipeline::Action
    attr_reader :node, :object_list

    def initialize(args = {})
      super(args)
      @node = args[:reference_node]
      @object_list = []
    end

    def self.process_images(args = {})
      # Generate a list of FigureObject consisting of
      # image elements.
      node = args[:node]

      img_node_list = node.xpath(".//*[local-name()='img']")
      object_list = []
      img_node_list.each do |img_node|
        # Image fragment. Just add object to list. No caption.
        object_list << FigureObject.new(
                name: args[:name],
                node: img_node
              )
      end
      return object_list
    end

    def self.process_image(node, args = {})
      # Image fragment. Just add object to list. No caption.
      return [
                FigureObject.new(
                  :name => args[:name],
                  :node => node
                )
              ]
    end

    def self.process_figure(nodes, args = {})
      # Processing a figure, which is assumed to consist
      # of one or more image and either a caption for each
      # image, or one caption for the entire figure.
      # For this figure, generate a list of Object consisting
      # of image fragments and associated image captions.

      # Find all caption nodes, ignoring the image nodes.
      captions_list = []
      nodes.each do |n|
        captions_list << n unless n.name == 'img' or n.name == 'video' or n.name == 'audio'
      end

      # As the nodes within figure are traversed, a caption
      # is associated with an image.
      # If the first node within the figure is a caption,
      # then we assume that all captions are located above
      # their images. Otherwise, the captions are assumed
      # to be below the image. If only one caption, then
      # that caption is associated with each image.
      caption_ndx = -1
      if captions_list.count > 0 and (nodes.first.name =='img' or nodes.first.name == 'video' or nodes.first.name == 'audio')
        caption_ndx = 0
      end

      img_list = []
      nodes.each do |node|
        if node.name == 'img' or node.name == 'video' or node.name == 'audio'
          caption = caption_ndx == -1 ? nil : captions_list[caption_ndx]
          img_list << FigureObject.new(
                  :node=> node,
                  :name => args[:name],
                  :caption=> caption
              )
        else
          caption_ndx += 1 unless caption_ndx +1 == captions_list.count
        end
      end

      # Return list of Object with image fragments and associated captions.
      return img_list
    end
  end
end
