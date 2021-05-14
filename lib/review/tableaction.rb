module UMPTG::Review

  #
  class TableAction < Action
    def process(args = {})
      super(args)

      @has_elements.each do |key, exists|
        @review_msg_list << "Table INFO:     has <#{key}>" if exists
        @review_msg_list << "Table Warning:  has no <#{key}>" unless exists
      end

      @status = Action.COMPLETED
    end
  end
end
