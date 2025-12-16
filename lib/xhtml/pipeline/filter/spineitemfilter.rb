module UMPTG::XHTML::Pipeline::Filter

  class SpineItemFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='div' and (
    @class='frontmatter' or @class='chapter' or @class='backmatter'
    )
    ]
    SXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :xhtml_spine_item
      a[:xpath] = XPATH
      super(a)

      @action_ndx = 0
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # <div> element

      action_list = []

      if reference_node.name == 'div'
        type = reference_node['epub:type']

        @action_ndx += 1
        action_list << UMPTG::XML::Pipeline::Actions::SpineItemAction.new(
                 name: name,
                 reference_node: reference_node,
                 path: args[:path],
                 item_ndx: @action_ndx,
                 info_message: \
                   "#{name}, #{reference_node.name} @type=\"#{type}\" division found, item_ndx=#{@action_ndx}"
             )
      end
      return action_list
    end

    def process_action_results(args = {})
      super(args)

      action_results = args[:action_results]
      logger = args[:logger]
=begin
      cnt = 0
      actions.each {|a| a.messages.each {|m| cnt += 1 if m.level == UMPTG::Message.WARNING } }

      unless actions.count == 0
        act_text_msg = "#{name}, tables with missing tbody=#{cnt}"
        logger.info(act_text_msg) if cnt == 0
        logger.warn(act_text_msg) unless cnt == 0
      end
=end
    end
  end
end
