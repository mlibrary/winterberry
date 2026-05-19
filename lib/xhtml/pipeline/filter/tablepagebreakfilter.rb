module UMPTG::XHTML::Pipeline::Filter

  class TablePagebreakFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='table'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_table_pagebreak,
              XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      super(
              issue,
              options: options
           )

      if issue.content.name == 'table'
        table_elem = issue.content
        id = table_elem['id'] || ""

        # Determine if the table caption contains pagebreak(s). If so,
        # move them outside of the table wrapper.
        x = ".//*[local-name()='caption' or local-name()='thead']" +
              "//*[@role='doc-pagebreak' or @epub:type='pagebreak']"
        table_elem.xpath(x).each do |n|
          msg = "#{issue.name}, #{table_elem.name} @id=\"#{id}\" found pagebreak #{n}"
          issue.actions << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                   name: issue.name,
                   reference_node: table_elem,
                   action: :add_previous,
                   markup: "<p>#{n.to_xml}</p>",
                   info_message: msg
               )
          n.remove
        end
      end
    end
  end
end
