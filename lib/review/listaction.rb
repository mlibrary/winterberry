module UMPTG::Review

  #
  class ListAction < Action
    def process(args = {})
      super(args)

      @has_elements.each do |elem_name, exists|
          add_warning_msg("Lists:  list item containing a <#{elem_name}>.") \
                if exists and @fragment.node.name == 'li'
          add_warning_msg("Lists:  definition term containing a <#{elem_name}>.") \
                if exists and @fragment.node.name == 'dt'
          add_warning_msg("Lists:  definition list item containing a <#{elem_name}>.") \
                if exists and @fragment.node.name == 'dd'
      end

      @status = Action.COMPLETED
    end
  end
end
