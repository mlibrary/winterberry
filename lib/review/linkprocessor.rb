class LinkProcessor < ReviewProcessor
  @@containers = [ 'a' ]

  def process(args = {})
    args[:containers] = @@containers
    fragments = super(args)

    ctr = 0
    fragments.each do |fragment|
      ctr += 1
      title = fragment.map['title']
      content = fragment.node.text

      fragment.review_msg_list << "Link #{ctr} INFO:    has title attribute" unless title.nil? or title.empty?
      fragment.review_msg_list << "Link #{ctr} INFO:    has no title attribute" if title.nil? or title.empty?
      fragment.review_msg_list << "Link #{ctr} INFO:    has content" unless content.nil? or content.empty?
      fragment.review_msg_list << "Link #{ctr} INFO:    has no content" if content.nil? or content.empty?
    end
    return fragments
  end
end
