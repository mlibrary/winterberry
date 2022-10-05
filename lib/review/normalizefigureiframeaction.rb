module UMPTG::Review

  class NormalizeFigureIframeAction < NormalizeAction

    def process(args = {})
      super(args)

      file_name = @properties[:file_name]
      node_name = @action_node.name

      caption_container = @action_node.xpath(".//*[@class='image_caption']").first

      @action_node.name = "figure"
      @action_node['id'] = file_name.gsub(/\./, '_')
      @action_node['style'] = "display:none"
      @action_node['data-fulcrum-embed-filename'] = file_name
      #markup = "<figure style=\"display:none\" data-fulcrum-embed-filename=\"#{rp}\"><figcaption/></figure>"

      add_info_msg("#{@reference_node.name}: converted figure container from #{node_name} to #{@action_node.name}.")
      add_info_msg("#{@reference_node.name}: set embed filename to #{file_name}.")

      figcaption_node = @action_node.document.create_element("figcaption")
      @action_node.add_child(figcaption_node)
      if caption_container.nil?
        add_warning_msg("#{@reference_node.name}:added empty image caption.")
      else
        figcaption_node.add_child(caption_container)
        add_info_msg("#{@reference_node.name}: added found image caption.")
      end

      div_node = @action_node.xpath("./*[1]").first
      if div_node.nil?
        add_error_msg("#{@reference_node.name}: unable to remove image container.")
      else
        div_node.remove
        add_info_msg("#{@reference_node.name}: removed image container #{div_node.name}.")
      end

      #@status = Action.COMPLETED
      @status = NormalizeAction.NORMALIZED
    end
  end
end
