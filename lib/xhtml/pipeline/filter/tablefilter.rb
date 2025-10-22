module UMPTG::XHTML::Pipeline::Filter

  class TableFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='table'
    ]
    SXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :xhtml_table
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # <table> element

      action_list = []

      if reference_node.name == 'table'
        tbody_node = reference_node.xpath("./*[local-name()='tbody']").first
        if tbody_node.nil?
          action_list << UMPTG::XML::Pipeline::Actions::TableMarkupAction.new(
                   name: name,
                   reference_node: reference_node,
                   action: :add_tbody,
                   warning_message: \
                     "#{name}, #{reference_node.name} tbody element not found"
               )
        else
          action_list << UMPTG::XML::Pipeline::Action.new(
                   name: name,
                   reference_node: reference_node,
                   info_message: \
                     "#{name}, #{reference_node.name} tbody element found"
               )
        end
      end
      return action_list
    end

    def process_action_results(args = {})
      action_results = args[:action_results]
      actions = args[:actions]
      logger = args[:logger]

      cnt = 0
      actions.each {|a| a.messages.each {|m| cnt += 1 if m.level == UMPTG::Message.WARNING } }

      act_text_msg = "tables with missing tbody:#{cnt}"
      logger.info(act_text_msg) if cnt == 0
      logger.warn(act_text_msg) unless cnt == 0
    end
  end
end
