module UMPTG::Review

  #
  class PackageMetadataAction < Action
    def process(args = {})
      super(args)

      @has_elements.each do |elem_name, exists|
          add_info_msg("Metadata:  contains <#{elem_name}>.") if exists
          add_info_msg("Metadata:  contains no <#{elem_name}>.") unless exists
      end
      @status = Action.COMPLETED
    end
  end
end
