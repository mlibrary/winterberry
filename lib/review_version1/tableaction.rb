module UMPTG::Review

  #
  class TableAction < Action
    def process(args = {})
      super(args)

      @has_elements.each do |key, exists|
        add_info_msg("Table:  has <#{key}>") if exists
        add_warning_msg("Table:  has no <#{key}>") unless exists
      end

      @status = Action.COMPLETED
    end
  end
end
