module UMPTG::Review

  class ImageAction < Action
    def initialize(args = {})
      super(args)

      @resource_path = @properties[:resource_path]
    end

    def process(args = {})
      super(args)

      rpath = @resource_path
      if rpath.nil? or rpath.strip.empty?
        rpath = "(not specified)"
        add_error_msg("image: \"\" has no src path")
      else
        add_info_msg(   "image: \"#{rpath}\" has src path")
      end

      alt = @reference_node['alt']
      add_info_msg(   "image: \"#{rpath}\" has alt text") unless alt.nil? or alt.empty?
      add_warning_msg("image: \"#{rpath}\" has no alt text") if alt.nil? or alt.empty?

      @status = Action.COMPLETED
    end
  end
end
