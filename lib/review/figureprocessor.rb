class FigureProcessor < ReviewProcessor
  @@containers = [ 'figure', 'img' ]
  @@children = [ 'figcaption' ]
  @@classes = [ 'figcap', 'figh' ]

  def process(args = {})
    args[:containers] = @@containers
    args[:children] = @@children
    args[:classes] = @@classes

    fragments = super(args)

    img_processor = ImgProcessor.new
    fragments.each do |fragment|
      if fragment.node.name == 'img'
        ImgProcessor.review(fragment)
        next
      end

      img_fragments = img_processor.process(
              :name => args[:name],
              :content => fragment.node.to_xml
          )

      # Determine if figure has a caption.
      caption_elem = ""
      fragment.has_elements.each do |elem_name, exists|
        if exists
          #fragment.review_msg_list << "Figure INFO:           has #{elem_name}"
          caption_elem = elem_name if caption_elem.empty?
        end
      end
      msg = "Figure INFO:           has caption (#{caption_elem})" unless caption_elem.empty?
      msg = "Figure Warning:        has no caption" if caption_elem.empty?
      fragment.review_msg_list << msg

      img_fragments.each do |img_frag|
        img_frag.review_msg_list.each do |msg|
          fragment.review_msg_list << "Figure " + msg
        end
      end
    end
    return fragments
  end
end
