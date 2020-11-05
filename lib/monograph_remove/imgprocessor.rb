module UMPTG::Monograph
  class ImgProcessor < UMPTG::Fragment::Processor
    @@imgselector = nil

    attr_reader :img_list

    def initialize
      super()
      reset
    end

    def process(args = {})
      #@@imgselector = ImgSelector.new if @@imgselector.nil?
      @@imgselector = UMPTG::Fragment::ContainerSelector.new if @@imgselector.nil?
      @@imgselector.containers = [ 'img', 'figure' ]
      args[:selector] = @@imgselector

      fragments = super(args)

      fragments.each do |fragment|
        if fragment.node.name == 'img'
          # Image fragment. Just add object to list. No caption.
          img = MonographObject.new(
                  :node => fragment.node,
                  :name => args[:name]
                )
          @img_list << img
          next
        end

        # Must be a figure fragment. Process the images and captions.
        nodes = fragment.node.xpath(".//*[local-name()='img' or local-name()='figcaption' or @class='figcap' or @class='figh']")
        #nodes = fragment.node.xpath(".//*[local-name()='img' or local-name()='p']")
        if nodes.count == 0
          # Empty figure element. Not expected, skip.
          next
        end

        captions_list = []
        nodes.each do |n|
          captions_list << n unless n.name == 'img'
        end
        caption_ndx = -1
        if captions_list.count > 0 and nodes.first.name =='img'
          caption_ndx = 0
        end
        nodes.each do |node|
          if node.name == 'img'
            caption = caption_ndx == -1 ? nil : captions_list[caption_ndx]
            @img_list << MonographObject.new(
                    :node=> node,
                    :name => args[:name],
                    :caption=> caption
                )
          else
            caption_ndx += 1 unless caption_ndx +1 == captions_list.count
          end
        end
      end
      return fragments
    end

    def reset
      @img_list = []
    end
  end
end
