module UMPTG::XML::Pipeline::Actions

  class TableMarkupAction < EmbedAction
    attr_reader :action, :markup

    ACTIONS = [ :add_tbody ]

    def initialize(issue, options: {})
      super(issue, options: options)

      raise "invalid action #{@properties[:action]}" \
            unless ACTIONS.include?(@properties[:action])
      @action = options[:action]
    end

    def resolve(options: {})
      super(options: options)

      reference_node = issue.content

      raise "invalid table element" unless reference_node.name == "table"

      case action
      when :add_tbody
        tr_list = reference_node.xpath(".//*[local-name()='tr' and parent::*[local-name()!='thead' and local-name()!='tfoot']]")
        if tr_list.empty?
          @status = UMPTG::Action.NO_ACTION
        else
          prev_node = tr_list.first.previous
          tbody_node = reference_node.document.create_element("tbody")
          tr_list.each {|tr| tbody_node.add_child(tr) }

          if prev_node.nil?
            reference_node.add_child(tbody_node)
          else
            prev_node.add_next_sibling(tbody_node)
          end
          add_info_msg("#{reference_node.name}: added tbody element.")
          @status = UMPTG::Action.COMPLETED
        end
      else
        add_error_msg("#{reference_node.name}: invalid action #{action}.")
        @status = UMPTG::Action.FAILED
      end
    end
  end
end
