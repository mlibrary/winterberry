module UMPTG::CSS::Pipeline

  class AddTableOverflowFilter < UMPTG::Pipeline::Filter

    CSS = <<-SCSS
.table_container {width: 100%;overflow-x: auto;overflow-y: auto;max-height: 90vh;max-width: 100rem;}
    SCSS

    def initialize(process, options: {})
      super(
              process,
              :css_add_table_overflow,
              options: options
            )
    end

    def select(content, options: {})
      issues = super(content, options: options)

      unless content.include?(".table_container ")
        issues << UMPTG::Issue.new(name: name, content: content)
      end
      return issues
    end

    def review(issue, options: {})
      return unless issue.name == name

      super(
              issue,
              options: options
           )

      issue.actions << UMPTG::CSS::Pipeline::AddTableOverflowAction.new(
                issue: issue,
                add_content: CSS,
                info_msg: "#{issue.name} action"
              )
    end
  end
end
