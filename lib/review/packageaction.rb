module UMPTG::Review

  #
  class PackageAction < Action
    def process(args = {})
      super(args)

      pck_version = @fragment.node["version"]
      case
      when pck_version.nil?
        @review_msg_list << "Package Warning:  EPUB version not specified."
      when pck_version[0] == '3'
        @review_msg_list << "Package INFO:     EPUB version is #{pck_version}"
      else
        @review_msg_list << "Package Warning:  EPUB version is #{pck_version}."
      end

      @has_elements.each do |elem_name, exists|
          @review_msg_list << "Package INFO:  contains <#{elem_name}>." if exists
          @review_msg_list << "Package INFO:  contains no <#{elem_name}>." unless exists
      end

      @status = Action.COMPLETED
    end
  end
end
