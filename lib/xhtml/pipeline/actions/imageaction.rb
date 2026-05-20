module UMPTG::XHTML::Pipeline::Actions

  class ImageAction < UMPTG::Pipeline::NormalizeAction
    def initialize(issue, options: {})
      super(issue, options: options)

      @reference_node = options[:reference_node]
      @resource_path = options[:resource_path]
    end

    def resolve(options: options)
      super(options: options)

      rpath = @resource_path
      if rpath.nil? or rpath.strip.empty?
        rpath = "(not specified)"
        add_error_msg("#{@issue.name}: \"\" has no src path")
      else
        add_info_msg(   "#{@issue.name}: \"#{rpath}\" has src path")
      end

      alt = @reference_node['alt'] || ""
      add_info_msg(   "#{@issue.name}: \"#{rpath}\" has alt text") unless alt.empty?
      add_warning_msg("#{@issue.name}: \"#{rpath}\" has no alt text") if alt.empty?

      #@status = Action.COMPLETED
      @status = Action.NO_ACTION
    end
  end
end
