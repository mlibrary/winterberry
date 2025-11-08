module UMPTG::XHTML::Pipeline::Filter

  class HeaderTitleFilter < UMPTG::XML::Pipeline::Filter

    XPATH = <<-SXPATH
    //*[
    local-name()='head'
    ]/*[
    local-name()='title'
    ]
    SXPATH

    def initialize(args = {})
      a = args.clone
      a[:name] = :xhtml_header_title
      a[:xpath] = XPATH
      super(a)
    end

    def create_actions(args = {})
      name = args[:name]
      reference_node = args[:reference_node]  # <title> element
      entry = args[:entry]
      epub = entry.files.epub

      action_list = []

      if reference_node.name == 'title'
        content = (reference_node.text || "").strip
        if content.empty? or content == "Header Title"
          m = epub.rendition.metadata.dc.elements.title.first.text
          action_list << UMPTG::XML::Pipeline::Actions::MarkupAction.new(
                    name: name,
                    reference_node: reference_node,
                    action: :replace_content,
                    markup: m,
                    warning_message: "#{name}, #{reference_node.name} no content"
                  )
        end
      end
      return action_list
    end
  end
end
