module UMPTG::Review

  class ImageAction < Action
    def process(args = {})
      super(args)

      src = @reference_node['src']
      alt = @reference_node['alt']

      add_info_msg(   "Image:  #{src} has alt text") unless alt.nil? or alt.empty?
      add_warning_msg("Image:  #{src} no alt text") if alt.nil? or alt.empty?

      @status = Action.COMPLETED
    end
  end
end
