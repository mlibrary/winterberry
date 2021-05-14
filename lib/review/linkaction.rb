module UMPTG::Review

  #
  class LinkAction < Action
    def process(args = {})
      super(args)

      id = @fragment.node['id']
      target = @fragment.node['target']
      title = @fragment.node['title']
      href = @fragment.node['href']
      content = @fragment.node.text

      label = ""
      label = "(@id=\"#{id}\")" unless id.nil? or id.empty?
      label = "(@href=\"#{href}\")" if (id.nil? or id.empty?) and !(href.nil? or href.empty?)
      label = "(@target=\"#{target}\")" if (id.nil? or id.empty?) and (href.nil? or href.empty?) and !(target.nil? or target.empty?)

      @review_msg_list << "Link #{label} INFO:    has title attribute" unless title.nil? or title.empty?
      @review_msg_list << "Link #{label} Warning:    has no title attribute" if title.nil? or title.empty?
      @review_msg_list << "Link #{label} INFO:    has content" unless content.nil? or content.empty?
      @review_msg_list << "Link #{label} Warning:    has no content" if content.nil? or content.empty?

      @status = Action.COMPLETED
    end
  end
end
