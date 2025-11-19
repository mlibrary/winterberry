module UMPTG::XHTML::Pipeline::Filter

  class PageTranslationFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    @class="facing-page-grid-container"
    ]
    SXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :xhtml_page_translation
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # <? class="facing-page-grid-container"> element

      action_list = []

      cl = (reference_node["class"] || "").strip
      if cl == 'facing-page-grid-container'
        id = reference_node['id'] || ""
        action = UMPTG::XML::Pipeline::Action.new(
                 name: name,
                 reference_node: reference_node,
                 info_message: \
                   "#{name}, #{reference_node.name} found @class=\"#{reference_node['class']}\" @id=\"#{id}\""
             )

        reference_node.xpath(".//*[@class='facing-page-grid-child']").each do |node|
          msg = "#{name}, #{node.name} found"
          node.attribute_nodes.each do |a|
            px = a.namespace.nil? ? "" : a.namespace.prefix + ":"
            anme = px.empty? ? a.name : px + a.name
            msg += " #{anme}=\"#{a.value}\""
          end
          action.add_info_msg(msg)
        end

        action_list << action
      end
      return action_list
    end
  end
end
