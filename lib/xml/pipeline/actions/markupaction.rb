module UMPTG::XML::Pipeline::Actions

  class MarkupAction < EmbedAction
    attr_reader :action, :markup

    ACTIONS = [ :add_child, :add_next, :add_previous, :replace_content, :replace_node ]

    def initialize(args = {})
      super(args)
      raise "invalid action #{@properties[:action]}" \
            unless ACTIONS.include?(@properties[:action])
      @action = @properties[:action]

      @markup = @properties[:markup]
      raise "empty markup" if @markup.strip.empty?
    end

    def process(args = {})
      super(args)

      fragment = reference_node.document.parse(markup)
      case action
      when :add_child
        #puts "reference_node:#{reference_node.name},fragment:#{fragment.to_xml}"
        reference_node.add_child(fragment)
        add_info_msg("#{reference_node.name}: added child markup #{markup}.")
      when :add_next
        reference_node.add_next_sibling(fragment)
        add_info_msg("#{reference_node.name}: added next sibling markup #{markup}.")
      when :add_previous
        reference_node.add_previous_sibling(fragment)
        add_info_msg("#{reference_node.name}: added previous sibling markup #{markup}.")
      when :replace_content
        reference_node.content = ""
        reference_node.add_child(fragment)
        add_info_msg("#{reference_node.name}: replaced content markup #{markup}.")
      when :replace_node
        reference_name = reference_node.name
        reference_node.add_next_sibling(fragment)
        reference_node.remove
        add_info_msg("#{reference_name}: replaced with #{markup}.")
      else
        add_error_msg("#{reference_node.name}: invalid action #{action}.")
      end
      @status = UMPTG::Action.COMPLETED
    end
  end
end
