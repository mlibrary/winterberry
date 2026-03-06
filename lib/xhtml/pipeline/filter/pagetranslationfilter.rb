module UMPTG::XHTML::Pipeline::Filter

  class PageTranslationFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    @class="facing-page-grid-container"
    ]
    SXPATH

    def initialize(options: nil)
      super(
              :xhtml_page_translation,
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

      cl = (issue.content["class"] || "").strip
      if cl == 'facing-page-grid-container'
        id = issue.content['id'] || ""
        action = UMPTG::XML::Pipeline::Action.new(
                 name: issue.name,
                 reference_node: issue.content,
                 info_message: \
                   "#{issue.name}, #{issue.content.name} found @class=\"#{issue.content['class']}\" @id=\"#{id}\""
             )

        issue.content.xpath(".//*[@class='facing-page-grid-child']").each do |node|
          msg = "#{issue.name}, #{node.name} found"
          node.attribute_nodes.each do |a|
            px = a.namespace.nil? ? "" : a.namespace.prefix + ":"
            anme = px.empty? ? a.name : px + a.name
            msg += " #{anme}=\"#{a.value}\""
          end
          action.add_info_msg(msg)
        end

        issue.actions << action
      end
    end
  end
end
