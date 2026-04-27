module UMPTG::XHTML::Pipeline::Actions

  class ImageAction < UMPTG::XML::Pipeline::Actions::NormalizeAction
    def initialize(args = {})
      super(args)

      @resource_path = @properties[:resource_path]
    end

    def resolve(args = {})
      super(args)

      rpath = @resource_path
      if rpath.nil? or rpath.strip.empty?
        rpath = "(not specified)"
        add_error_msg("#{name}: \"\" has no src path")
      else
        add_info_msg(   "#{name}: \"#{rpath}\" has src path")
      end

      alt = @reference_node['alt']
      add_info_msg(   "#{name}: \"#{rpath}\" has alt text") unless alt.nil? or alt.empty?
      add_warning_msg("#{name}: \"#{rpath}\" has no alt text") if alt.nil? or alt.empty?

      #@status = Action.COMPLETED
      @status = Action.NO_ACTION
    end
  end
end
