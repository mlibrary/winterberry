module UMPTG::XML::Reviewer::Filter

  class LinkFilter < UMPTG::XML::Pipeline::Filter::Filter

    LINK_XPATH = <<-SXPATH
    //*[
    local-name()='a'
    ]
    SXPATH

    def initialize(args = {})
      args[:name] = :links
      args[:selector] = UMPTG::XML::Reviewer::ElementSelector.new(
              selection_xpath: LINK_XPATH
            )
      super(args)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]

      action = UMPTG::XML::Pipeline::Action::Action.new(args)
      id = reference_node['id']
      target = reference_node['target']
      title = reference_node['title']
      href = reference_node['href']
      content = reference_node.text

      label = ""
      label = "(@id=\"#{id}\")" unless id.nil? or id.empty?
      label = "(@href=\"#{href}\")" if (id.nil? or id.empty?) and !(href.nil? or href.empty?)
      label = "(@target=\"#{target}\")" if (id.nil? or id.empty?) and (href.nil? or href.empty?) and !(target.nil? or target.empty?)

      action.add_info_msg("link #{label}: has title attribute") unless title.nil? or title.empty?
      action.add_warning_msg("link #{label}: has no title attribute") if title.nil? or title.empty?
      action.add_info_msg("link #{label}: has content") unless content.nil? or content.empty?
      action.add_warning_msg("link #{label}: has no content") if content.nil? or content.empty?

      return [ action ]
    end
  end
end
