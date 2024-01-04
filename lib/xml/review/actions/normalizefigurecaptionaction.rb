module UMPTG::XML::Review::Actions

  require_relative("normalizefigureaction")

  class NormalizeFigureCaptionAction < NormalizeFigureAction

    def process(args = {})
      super(args)

      cap_list = @properties[:cap_list]

      nested_node = cap_list.first.document.create_element("figcaption")
      add_info_msg("image: created figcaption.")
      cap_list.first.add_previous_sibling(nested_node)
      cap_list.each do |node|
        args[:caption_node] = node
        NormalizeFigureAction.normalize_caption_class(args)

        nested_node.add_child(node)
        add_info_msg("image: wrapped \"#{node.name} within a figcaption.")
      end
=begin
      node_name = @action_node.name
      @action_node.name = "figcaption"
      add_info_msg("image: \"#{@resource_path}\" converted figure caption from #{node_name} to #{@action_node.name}.")
=end

      @status = UMPTG::Action.COMPLETED
    end
  end
end
