module UMPTG::FOPS1065::XHTML::Pipeline::Filter

  class FootnoteFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='sup'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_footnote,
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

      if issue.content.name == 'sup'
        issue.actions << UMPTG::XML::Pipeline::Action.new(
                 name: issue.name,
                 reference_node: issue.content,
                 warning_message: \
                   "#{issue.name}, #{issue.content} found"
             )
      end
    end
  end
end
