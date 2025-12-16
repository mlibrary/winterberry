module UMPTG::XML::Pipeline::Actions

  class SpineItemAction < NormalizeAction
    def process(args = {})
      super(args)

      reference_node = @properties[:reference_node]
      path = @properties[:path]
      item_ndx = @properties[:item_ndx]

      type = reference_node["epub:type"] || ""
      section_type = type

      prefix = item_ndx.to_s.rjust(3, "0")
      section_file = File.join(File.dirname(path), "#{prefix}_#{section_type}" + File.extname(path))
      add_info_msg("created section #{section_file}")

      #@status = UMPTG::Action.COMPLETED
    end
  end
end

