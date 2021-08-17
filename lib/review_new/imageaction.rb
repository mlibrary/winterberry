module UMPTG::Review

  class ImageAction < Action
    def initialize(args = {})
      super(args)

      @resource_path = @properties[:resource_path]
      raise "Error: #{reference_node.name} with no @src value." if @resource_path.nil?
    end

    def process(args = {})
      super(args)

      alt = @reference_node['alt']
      add_info_msg(   "image: \"#{@resource_path}\" has alt text") unless alt.nil? or alt.empty?
      add_warning_msg("image: \"#{@resource_path}\" no alt text") if alt.nil? or alt.empty?

      @status = Action.COMPLETED
    end
  end
end
