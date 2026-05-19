module UMPTG::XHTML::Pipeline::Filter

  class TableOverflowFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='table'
    ]
    SXPATH

    def initialize(process, options: {})
      super(
              process,
              :xhtml_table_overflow,
              XPATH,
              options: options
            )
    end

    def review(issue, options: {})
      super(
              issue,
              options: options
           )

      name = issue.name

      if issue.content.name == 'table'
        table_elem = issue.content
        id = table_elem['id'] || ""

        # Determine whether the table is wrapped within a figure and within
        # div/*[@class="table_container" and @tabindex="0">].
        figure_elem = table_elem.xpath("./ancestor::*[local-name()='figure'][1]").first
        div_elem = table_elem.xpath("./ancestor::*[local-name()='div' and @class='table_container' and @tabindex='0'][1]").first

        if !(figure_elem.nil? or div_elem.nil?)
          # Found both. Issue info message.
          msg = "#{issue.name}, #{table_elem.name} @id=\"#{id}\" " +
              "overflow markup found #{figure_elem.name}//#{div_elem.name}" +
              "[@class=\"#{div_elem['class']}\" and @tabindex=\"#{div_elem['tabindex']}\"]"
          issue.actions << UMPTG::XML::Pipeline::Actions::Action.new(
                   name: issue.name,
                   reference_node: issue.content,
                   info_message: msg
               )
        else
          # Either figure element or div not found.
          msg = "#{issue.name}, #{table_elem.name} @id=\"#{id}\" " +
              "overflow markup not found."
          issue.actions << UMPTG::XHTML::Pipeline::Actions::NormalizeTableOverflowAction.new(
                   name: issue.name,
                   reference_node: issue.content,
                   warning_message: msg
               )
        end
      end
    end
  end
end
