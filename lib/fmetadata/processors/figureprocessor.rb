module UMPTG::FMetadata::Processors

  class FigureProcessor < EntryProcessor

    def new_action(args = {})
      action = UMPTG::FMetadata::FigureAction.new(
          name: args[:name],
          fragment: args[:fragment]
          )
      return action
    end

    def self.process_images(fragments, args = {})
      # Generate a list of ImageObject consisting of
      # image fragments.
      img_list = []
      fragments.each do |fragment|
        if fragment.node.name == 'img'
          # Image fragment. Just add object to list. No caption.
          img_list << UMPTG::FMetadata::FigureObject.new(
                  :node => fragment.node,
                  :name => args[:name]
                )
        end
      end
      return img_list
    end

    def self.process_image(fragment, args = {})
      # Image fragment. Just add object to list. No caption.
      return [
                UMPTG::FMetadata::FigureObject.new(
                  :node => fragment.node,
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
          img_list << UMPTG::FMetadata::FigureObject.new(
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