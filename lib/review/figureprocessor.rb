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

      fragment.has_elements.each do |key, exists|
        fragment.review_msg_list << "Figure INFO:     has <#{key}>" if exists
        fragment.review_msg_list << "Figure Warning:  has no <#{key}>" unless exists
      end

      img_fragments.each do |img_frag|
        img_frag.review_msg_list.each do |msg|
          fragment.review_msg_list << "Figure " + msg
        end
      end
    end
    return fragments
  end
end
