module UMPTG::Review

  #
  class ImgAction < Action
    def process(args = {})
      super(args)

      src = @fragment.node['src']
      alt = @fragment.node['alt']

      add_info_msg("Image:     #{src} has alt text") unless alt.nil? or alt.empty?
      add_warning_msg("Image:  #{src} no alt text") if alt.nil? or alt.empty?
      #@review_msg_list << msg

      # Attach the list XML fragment objects processed to this
      # Action and set it status COMPLETED.
      @status = Action.COMPLETED
    end
  end
end
