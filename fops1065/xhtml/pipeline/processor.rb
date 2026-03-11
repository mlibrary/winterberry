module UMPTG::FOPS1065::XHTML::Pipeline

  class Processor < UMPTG::XML::Pipeline::Processor

    def initialize(name, filters: nil, options: {}, logger: nil)

      m_filters = filters.nil? ? UMPTG::FOPS1065::XHTML::Pipeline.FILTERS : \
                    filters.merge(UMPTG::FOPS1065::XHTML::Pipeline.FILTERS)
      super(
            name,
            filters: m_filters,
            options: options,
            logger: logger
          )
    end

    def review(issues, options: {})
      super(issues, options: options)

      lm = {}
      issues.each do |issue|
        if lm.key?(issue.content.content)
          lm[issue.content.content] << issue
        else
          lm[issue.content.content] = [issue]
        end
      end
      lm.each do |k,list|
        next if list.count != 2
        issue = UMPTG::Issue.new(name: list[0].name, content: list[0].content)

        m = "<a id=\"footnote_ref#{k}\" href=\"\#footnote_#{k}\">#{k}</>"
        issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                  name: issue.name,
                  reference_node: list[0].content,
                  action: :replace_content,
                  markup: m,
                  warning_message: "#{issue.name}, #{list[0].content.name} no link"
                )

        m = "<a id=\"footnote_#{k}\" href=\"\#footnote_ref#{k}\">#{k}</>"
        issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                  name: issue.name,
                  reference_node: list[1].content,
                  action: :replace_content,
                  markup: m,
                  warning_message: "#{issue.name}, #{list[1].content.name} no link"
                )
        issues << issue
      end
    end
  end
end
