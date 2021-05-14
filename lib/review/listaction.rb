module UMPTG::Review

  #
  class ListAction < Action
    def process(args = {})
      super(args)

      @has_elements.each do |elem_name, exists|
          @review_msg_list << "Lists Warning:  list item containing a <#{elem_name}>." \
                if exists and @fragment.node.name == 'li'
          @review_msg_list << "Lists Warning:  definition term containing a <#{elem_name}>." \
                if exists and @fragment.node.name == 'dt'
          @review_msg_list << "Lists Warning:  definition list item containing a <#{elem_name}>." \
                if exists and @fragment.node.name == 'dd'
      end

      @status = Action.COMPLETED
    end
  end
end
