module UMPTG::XHTML::Pipeline::Filter

  class TableFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='table'
    ]
    SXPATH

    def initialize(options: nil)
      super(
              name: :xhtml_table,
              xpath: XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      return unless issue.name == name

      super(
              issue,
              options: options
           )

      name = issue.name
      reference_node = issue.content  # <table> element

      if reference_node.name == 'table'
        id = reference_node['id']

        tbody_node = reference_node.xpath("./*[local-name()='tbody']").first
        if tbody_node.nil?
          issue.actions << UMPTG::XML::Pipeline::Actions::TableMarkupAction.new(
                   name: name,
                   reference_node: reference_node,
                   action: :add_tbody,
                   warning_message: \
                     "#{name}, #{reference_node.name} @id=\"#{id}\" tbody element not found"
               )
        else
          issue.actions << UMPTG::XML::Pipeline::Action.new(
                   name: name,
                   reference_node: reference_node,
                   info_message: \
                     "#{name}, #{reference_node.name} @id=\"#{id}\" tbody element found"
               )
        end

        if reference_node.key?('fromhtml')
          # Invalid attribute. Remove.
          issue.actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                   name: name,
                   reference_node: reference_node,
                   attribute_name: "fromhtml",
                   warning_message: \
                     "#{name}, #{reference_node.name} found invalid attribute @fromhtml"
               )
        end
      end
    end

    def report(issues, options: {}, logger:)
      super(issues, options: options, logger: logger)

      cnt = 0
      issues.each do |issue|
        next if issue.actions.count == 0

        issue.actions.each {|a| a.messages.each {|m| cnt += 1 if m.level == UMPTG::Message.WARNING } }
      end
      act_text_msg = "#{name}, tables with missing tbody=#{cnt}"
      logger.info(act_text_msg) if cnt == 0
      logger.warn(act_text_msg) unless cnt == 0
    end
  end
end
