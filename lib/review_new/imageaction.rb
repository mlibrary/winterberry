module UMPTG::Review

  class ImageAction < Action
    def initialize(args = {})
      super(args)

      resource_path = reference_node['src']
      if resource_path.nil? or resource_path.strip.empty?
        raise "Error: #{reference_node.name} with no @src value."
      else
        @properties[:xpath] = sprintf("//*[local-name()='#{reference_node.name}' and @src='#{resource_path}']")
      end
    end

    def process(args = {})
      super(args)

      resource_path = @reference_node.key?('src') ? @reference_node['src'] : "unspecified"
      alt = @reference_node['alt']

      add_info_msg(   "image: \"#{resource_path}\" has alt text") unless alt.nil? or alt.empty?
      add_warning_msg("image: \"#{resource_path}\" no alt text") if alt.nil? or alt.empty?

      @status = Action.COMPLETED
    end
  end
end
