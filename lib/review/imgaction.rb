module UMPTG::Review

  #
  class ImgAction < Action
    def process(args = {})
      super(args)

      src = @fragment.node['src']
      alt = @fragment.node['alt']

      msg = "Image INFO:    #{src} has alt text" unless alt.nil? or alt.empty?
      msg = "Image Warning: #{src} no alt text" if alt.nil? or alt.empty?
      @review_msg_list << msg

      # Attach the list XML fragment objects processed to this
      # Action and set it status COMPLETED.
      #@object_list = olist
      @status = Action.COMPLETED
    end
  end
end
