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

      add_info_msg("Link #{label}: has title attribute") unless title.nil? or title.empty?
      add_warning_msg("Link #{label}: has no title attribute") if title.nil? or title.empty?
      add_info_msg("Link #{label}: has content") unless content.nil? or content.empty?
      add_warning_msg("Link #{label}: has no content") if content.nil? or content.empty?

      @status = Action.COMPLETED
    end
  end
end
