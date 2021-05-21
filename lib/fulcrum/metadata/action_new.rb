module UMPTG::Fulcrum::Metadata

  # Class is the base for resource metadata processing.
  class Action < UMPTG::Action
    attr_reader :fragment
    attr_accessor :object_list

    # Arguments:
    #   :name         Content identifier, e.g. EPUB entry name or file name.
    #   :fragment     XML fragment for Marker to process.
    #   :object_list  Optionally add a list of fragments to process.
    def initialize(args = {})
      super(args)

      @fragment = @properties[:fragment]
      @object_list = []
      #@object_list = @properties.key?(:object_list) ? @properties[:object_list] : []
    end

    def self.process_images(fragments, args = {})
      # Generate a list of ImageObject consisting of
      # image fragments.
      img_list = []
      fragments.each do |fragment|
        if fragment.node.name == 'img'
          # Image fragment. Just add object to list. No caption.
          img_list << FigureObject.new(
                  :node => fragment.node,
                  :name => args[:name]
                )
        end
      end
      return img_list
    end

    def self.process_image(ref_node, args = {})
      # Image fragment. Just add object to list. No caption.
      return [
                FigureObject.new(
                  :node => ref_node,
                  :name => args[:name]
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
        captions_list << n unless n.name == 'img'
      end

      # As the nodes within figure are traversed, a caption
      # is associated with an image.
      # If the first node within the figure is a caption,
      # then we assume that all captions are located above
      # their images. Otherwise, the captions are assumed
      # to be below the image. If only one caption, then
      # that caption is associated with each image.
      caption_ndx = -1
      if captions_list.count > 0 and nodes.first.name =='img'
        caption_ndx = 0
      end

      img_list = []
      nodes.each do |node|
        if node.name == 'img'
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
