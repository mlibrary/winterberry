module UMPTG::EPUB::Processors
  class ImageProcessor < UMPTG::Fragment::Processor
    attr_reader :img_list

    def initialize
      super()
      reset
    end

    def process(args = {})
      fragments = super(args)
      return fragments
    end

    def self.process_images(fragments, args = {})
      img_list = []
      fragments.each do |fragment|
        if fragment.node.name == 'img'
          # Image fragment. Just add object to list. No caption.
          img_list << Object.new(
                  :node => fragment.node,
                  :name => args[:name]
                )
        end
      end
      return img_list
    end

    def self.process_figures(nodes, args = {})
      captions_list = []
      nodes.each do |n|
        captions_list << n unless n.name == 'img'
      end
      caption_ndx = -1
      if captions_list.count > 0 and nodes.first.name =='img'
        caption_ndx = 0
      end

      img_list = []
      nodes.each do |node|
        if node.name == 'img'
          caption = caption_ndx == -1 ? nil : captions_list[caption_ndx]
          img_list << Object.new(
                  :node=> node,
                  :name => args[:name],
                  :caption=> caption
              )
        else
          caption_ndx += 1 unless caption_ndx +1 == captions_list.count
        end
      end
      return img_list
    end

    def reset
      @img_list = []
    end
  end
end
