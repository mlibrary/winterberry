class LinkProcessor < ReviewProcessor

  def process(args = {})
    selector = ContainerSelector.new
    selector.containers = [ 'a' ]
    args[:selector] = selector

    fragments = super(args)

    ctr = 0
    fragments.each do |fragment|
      ctr += 1
      frag_map = fragment.map
      id = frag_map['id']
      target = frag_map['target']
      title = frag_map['title']
      href = frag_map['href']
      content = fragment.node.text

      label = ""
      label = "(@id=\"#{id}\")" unless id.nil? or id.empty?
      label = "(@href=\"#{href}\")" if (id.nil? or id.empty?) and !(href.nil? or href.empty?)
      label = "(@target=\"#{target}\")" if (id.nil? or id.empty?) and (href.nil? or href.empty?) and !(target.nil? or target.empty?)

      fragment.review_msg_list << "Link \##{ctr} #{label} INFO:    has title attribute" unless title.nil? or title.empty?
      fragment.review_msg_list << "Link \##{ctr} #{label} Warning:    has no title attribute" if title.nil? or title.empty?
      fragment.review_msg_list << "Link \##{ctr} #{label} INFO:    has content" unless content.nil? or content.empty?
      fragment.review_msg_list << "Link \##{ctr} #{label} Warning:    has no content" if content.nil? or content.empty?
    end
    return fragments
  end
end
