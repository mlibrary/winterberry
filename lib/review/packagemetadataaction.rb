module UMPTG::Review

  #
  class PackageMetadataAction < Action
    def process(args = {})
      super(args)

      @has_elements.each do |elem_name, exists|
          @review_msg_list << "Metadata INFO:  contains <#{elem_name}>." if exists
          @review_msg_list << "Metadata INFO:  contains no <#{elem_name}>." unless exists
      end
      @status = Action.COMPLETED
    end
  end
end
