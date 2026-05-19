module UMPTG::XHTML::Pipeline::Filter

  class TableTbodyFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='table'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_table_tbody,
              XPATH,
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

      if issue.content.name == 'table'
        id = issue.content['id']

        tbody_node = issue.content.xpath("./*[local-name()='tbody']").first
        if tbody_node.nil?
          issue.actions << UMPTG::XML::Pipeline::Actions::TableMarkupAction.new(
                   name: issue.name,
                   reference_node: issue.content,
                   action: :add_tbody,
                   warning_message: \
                     "#{issue.name}, #{issue.content.name} @id=\"#{id}\" tbody element not found"
               )
        else
          issue.actions << UMPTG::XML::Pipeline::Action.new(
                   name: issue.name,
                   reference_node: issue.content,
                   info_message: \
                     "#{issue.name}, #{issue.content.name} @id=\"#{id}\" tbody element found"
               )
        end

        if issue.content.key?('fromhtml')
          # Invalid attribute. Remove.
          issue.actions << UMPTG::XML::Pipeline::Actions::RemoveAttributeAction.new(
                   name: issue.name,
                   reference_node: issue.content,
                   attribute_name: "fromhtml",
                   warning_message: \
                     "#{issue.name}, #{issue.content.name} found invalid attribute @fromhtml"
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
