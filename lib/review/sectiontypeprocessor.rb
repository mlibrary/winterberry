module UMPTG::Review
  class SectionTypeProcessor < EntryProcessor

    XPATH = <<-XP
    //*[
    local-name()='body'
    ]//*[
    local-name()='section'
    and (@role or @epub:type)
    ]
    XP

    def initialize(args = {})
      args[:selector] = ElementSelector.new(
              selection_xpath: XPATH
            )
      super(args)
    end

    def new_action(args = {})
      a = args.clone
      a[:epub] = @epub

      reference_node = a[:reference_node]
      title_node = reference_node.document.xpath("//*[local-name()='head']/*[local-name()='title']").first
      title = title_node.nil? ? "" : title_node.content
      msg = "#{title},id:#{:reference_node['id']},role:#{reference_node['role']},type:#{reference_node['epub:type']}"
      action = Action.new(a)
      action.add_info_msg(msg)
      return [ action ]
    end
  end
end
