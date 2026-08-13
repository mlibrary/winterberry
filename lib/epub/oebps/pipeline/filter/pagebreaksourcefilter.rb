module UMPTG::EPUB::OEBPS::Pipeline::Filter

  class PageBreakSourceFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='metadata'
    ]/*[
    local-name()='meta' and @property='pageBreakSource'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :epub_oebps_pagebreaksource,
              XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      super(
              issue,
              options: options
           )

      issue.actions << UMPTG::XML::Pipeline::Action.new(
               issue,
               options: {
                   info_message: \
                     "#{issue.name}, found #{issue.content}"
                   }
           )
    end

    def self.review_issues(entry_actions, access_mode_info, options: {})
      metadata_node = access_mode_info.oebps_entry_action.entry.document.xpath("//*[local-name()='metadata']").first
      raise "unable to locate OEBPS metadata node" if metadata_node.nil?

      issues = access_mode_info.oebps_entry_action.issues
      pbs_issues = issues.select {|i| i.name == :epub_oebps_pagebreaksource }

      if pbs_issues.count == 0
        issue = UMPTG::Issue.new(
                  name: :epub_oebps_pagebreaksource,
                  content: metadata_node
                )
        issues << issue

        ident_node = metadata_node.xpath("./*[name()='dc:identifier']").first
        if ident_node.nil? or ident_node.text.empty?
          issue.actions << UMPTG::XML::Pipeline::Action.new(
                   issue,
                   options: {
                       warning_message: \
                         "#{issue.name}, #{issue.content.name} dc:identifier not found"
                       }
               )
        else
          markup = "<meta property=\"pageBreakSource\">#{ident_node.text}</>"
          issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                    issue,
                    options: {
                          action: :add_child,
                          markup: markup,
                          warning_message: "#{issue.name}, missing meta/@property=\"pageBreakSource\""
                        }
                  )
        end
      end
    end
  end
end
