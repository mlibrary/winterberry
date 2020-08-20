class ImgProcessor < ReviewProcessor
  #@@containers = [ 'img' ]

  def process(args = {})
    #args[:containers] = @@containers

    selector = ContainerSelector.new
    selector.containers = [ 'img' ]
    args[:selector] = selector

    fragments = super(args)

    fragments.each do |fragment|
      ImgProcessor.review(fragment)
    end
    return fragments
  end

  def self.review(fragment)
    src = fragment.map['src']
    alt = fragment.map['alt']

    fragment.review_msg_list << "Image INFO:    #{src} has alt text" unless alt.nil? or alt.empty?
    fragment.review_msg_list << "Image Warning: #{src} no alt text" if alt.nil? or alt.empty?
  end
end
